class IceYield < ActiveRecord::Base
  attr_accessible :ice_ore_id, :ice_product_id, :quantity
  
  belongs_to :ice_ore
  belongs_to :ice_product
  
  default_scope { order('id') }
  
  def percentage
    total_yield = ice_ore.ice_yields.sum(:quantity)
    (quantity.to_f / total_yield) * 100
  end
end
