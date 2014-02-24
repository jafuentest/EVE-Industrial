# == Schema Information
#
# Table name: ice_ores
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  volume     :float
#  central_id :integer
#

class IceOre < ActiveRecord::Base
  attr_accessible :central_id, :name, :volume
  
  has_many :ice_yields
  has_many :ice_products, through: :ice_yields
  
  default_scope { order('id') }
  
  def refine_revenue(price_list, station_yield, skills, refinery_tax)
    revenue = 0
    new_volume = 0
    recycling_constant = 37.5
    refining_factor = 1 + (skills[:refining_skill].to_i * 0.02)
    efficiency_factor = 1 + (skills[:refinery_efficiency_skill].to_i * 0.04)
    specialization_factor = 1 + (skills[:ice_processing_skill].to_i * 0.05)
    net_yield = station_yield.to_f + recycling_constant * refining_factor * efficiency_factor * specialization_factor
    net_yield = 100 if net_yield > 100
    net_yield *= (100 - refinery_tax.to_f) / 100
    net_yield /= 100
    ice_yields.each do |y|
      price = price_list[y.ice_product.central_id]
      revenue += y.quantity * net_yield * price
      new_volume += y.quantity * y.ice_product.volume
    end
    new_volume *= net_yield
    volume_reduction = ((volume-new_volume) / volume) * 100
    net_yield *= 100
    { :revenue => revenue, :yield => net_yield, :volume => volume_reduction }
  end
end
