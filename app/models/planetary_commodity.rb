class PlanetaryCommodity < ActiveRecord::Base
  attr_accessible :central_id, :name, :quantity, :tier, :volume
  
  has_many :schematics, :foreign_key => :output_id
  has_many :requirements, :through => :schematics, :source => :input
  
  def custom_office_tax (type, tax)
    tax /= 100.0
    case tier
      when 0
        base_tax = 4.0
      when 1
        base_tax = 400.0
      when 2
        base_tax = 7200.0
      when 3
        base_tax = 60000.0
      when 4
        base_tax = 1200000.0
    end
    
    if type == :export
      base_tax * tax
    elsif type == :import
      base_tax * tax / 2
    else
      raise 'Unknown transaction'
    end
  end
  
  def inputs (desired_tier = -1)
    if desired_tier == -1
      desired_tier = tier - 1
    end
    
    if desired_tier < tier
      new_schematics = schematics
      new_tier = tier - 1
      while new_tier > desired_tier
        aux_schematics = []          
        new_schematics.each do |schematic|
          aux_schematics.concat(schematic.input.schematics)
        end
        new_schematics = aux_schematics
        new_tier -= 1
      end
      new_schematics
    else
      raise 'Invalid input tier'
    end
  end
  
  def processing_cost (prices, taxes, base_tier)
    market_tax = 1 - (taxes[:market] / 100.0)
    cost = 0
    insufficient_sell_orders = false
    inputs(base_tier).each do |schematic|
      price = prices[:sell][schematic.input.central_id]
      if price == 0
        insufficient_sell_orders = true
      else
        cost += schematic.quantity * (price + schematic.input.custom_office_tax(:import, taxes[:customs_office]))
      end
    end
    
    if insufficient_sell_orders
      0
    else
      cost
    end
  end
  
  def processing_revenue (prices, taxes, processors, base_tier = 0)
    market_tax = 1 - (taxes[:market] / 100.0)
    revenue = (prices[:buy][central_id] * market_tax - custom_office_tax(:export, taxes[:customs_office])) * quantity
    cost = processing_cost(prices, taxes, base_tier)
    hourly_production = tier == 1 ? 2 : 1
    if cost == 0
      { :revenue => 0, :roi => 0 }
    else
      { :revenue => (hourly_production * revenue) - cost, :roi => ((revenue - cost) / cost) * 100 }
    end
  end
  
  def hour_revenue (price, taxes, processors)
    market_tax = 1 - taxes[:market] / 100.0
    hourly_production = tier == 1 ? quantity * 2 : quantity
    ((price * market_tax) - (custom_office_tax(:export, taxes[:customs_office]))) * quantity * processors[tier]
  end  
end
