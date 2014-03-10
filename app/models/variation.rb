# == Schema Information
#
# Table name: variations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  ore_id     :integer
#  bonus      :integer
#  central_id :integer
#

class Variation < ActiveRecord::Base
  attr_accessible :bonus, :central_id, :name, :ore_id
  
  belongs_to :ore
  
  has_many :yields
  has_many :minerals, through: :yields
  
  default_scope { order('id') }

  def name
    if self[:name].nil? || self[:name].empty?
      ore.name
    else
      self[:name] + ' ' + ore.name
    end
  end
  
  def batch_size
    ore.refine
  end
  
  def raw_revenue(price)
    price / volume
  end
  
  def refine_volume
    ore.refine_volume
  end
  
  def volume
    ore.volume
  end
  
  def refining_yield(station_yield, skills, refinery_tax)
    recycling_constant = 37.5
    refining_factor = 1 + (skills[:refining_skill].to_i * 0.02)
    efficiency_factor = 1 + (skills[:refinery_efficiency_skill].to_i * 0.04)
    specialization_factor = 1 + (skills[ore.name].to_i * 0.05)
    refining_yield = station_yield.to_f + recycling_constant * refining_factor * efficiency_factor * specialization_factor
    refining_yield = 100 if refining_yield > 100
    refining_yield *= (100 - refinery_tax.to_f) / 100
    refining_yield /= 100
  end
  
  def refine_revenue(prices, station_yield, skills, refinery_tax)
    net_yield = refining_yield station_yield, skills, refinery_tax
    revenue = 0
    refined_volume = 0
    
    yields.each do |y|
      price = prices[y.mineral.central_id]
      revenue += y.quantity * net_yield * price
      refined_volume += y.quantity
    end
    
    revenue /= refine_volume
    refined_volume *= Mineral::VOLUME * net_yield
    volume_reduction = ((refine_volume-refined_volume) / refine_volume) * 100
    raw_revenue = raw_revenue(prices[central_id])
    gain = ((revenue - raw_revenue) / raw_revenue) * 100
    { :revenue => revenue, :volume_reduction => volume_reduction, :efficiency => net_yield * 100, :gain => gain }
  end
  
  def martket_refining(prices, station_yield, skills, taxes)
    net_yield = refining_yield station_yield, skills, taxes[:refinery]
    revenue = 0
    
    yields.each do |y|
      price = prices[:buy][y.mineral.central_id]
      revenue += y.quantity * net_yield * price
    end
    
    revenue *= 1 - taxes[:market] / 100
    cost = prices[:sell][central_id] * batch_size
    return_on_investment = ((revenue - cost) / cost) * 100
    { :return_on_investment => return_on_investment, :efficiency => net_yield * 100 }
  end
end
