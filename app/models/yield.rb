class Yield < ActiveRecord::Base
  attr_accessible :bonus, :quantity, :mineral_id, :variation_id
  
  belongs_to :mineral
  belongs_to :variation
  
  def material_yield
    quantity / variation.refine_volume
  end
end
