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
  
  def volume
    ore.volume
  end
  
  def refine_volume
    ore.refine_volume
  end
  
  def raw_revenue(price)
    price / volume
  end
  
  def refine_revenue(price_list, station_yield, skills, refinery_tax)
    revenue = 0
    volume = 0
    recycling_constant = 37.5
    refining_factor = 1 + (skills[:refining_skill].to_i * 0.02)
    efficiency_factor = 1 + (skills[:refinery_efficiency_skill].to_i * 0.04)
    specialization_factor = 1 + (skills[ore.name].to_i * 0.05)
    net_yield = station_yield.to_f + recycling_constant * refining_factor * efficiency_factor * specialization_factor
    net_yield = 100 if net_yield > 100
    net_yield *= (100 - refinery_tax.to_f) / 100
    net_yield /= 100
    yields.each do |y|
      price = price_list[y.mineral.central_id]
      revenue += y.quantity * net_yield * price
      volume += y.quantity
    end
    revenue /= refine_volume
    volume *= 0.01 * net_yield
    volume = ((refine_volume-volume) / refine_volume) * 100
    net_yield *= 100
    { :revenue => revenue, :yield => net_yield, :volume => volume }
  end
end
