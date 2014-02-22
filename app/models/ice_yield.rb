class IceYield < ActiveRecord::Base
  attr_accessible :ice_ore_id, :ice_product_id, :quantity
  
  belongs_to :ice_ore
  belongs_to :ice_product
  
  default_scope { order('id') }
end
