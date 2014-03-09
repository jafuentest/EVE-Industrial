class PlanetaryCommodity < ActiveRecord::Base
  attr_accessible :central_id, :name, :quantity, :tier, :volume
  
  has_one :schematic, :foreign_key => :input_id
  has_many :schematics, :foreign_key => :output_id
  has_many :requirements, :through => :schematics, :source => :output
  
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
  
  def processing_revenue(prices, custom_office_tax, market_tax)
    market_tax = 1 - market_tax / 100.0
    revenue = prices[:buy][central_id] * quantity * market_tax
    cost = 0
    insufficient_sell_orders = false
    schematics.each do |schematic|
      price = prices[:sell][schematic.input.central_id]
      if price == 0
        insufficient_sell_orders = true
      else
        cost += price * schematic.quantity
        cost += schematic.quantity * schematic.input.custom_office_tax(:import, custom_office_tax)
      end
    end
    
    if insufficient_sell_orders
      0
    else
      ((revenue - cost) / cost) * 100
    end
  end
  
  def hour_revenue(price, processors)
    hourly_production = tier == 1 ? quantity * 2 : quantity
    price * hourly_production * processors[tier]
  end
end
