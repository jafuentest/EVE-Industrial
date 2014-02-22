class IceProduct < ActiveRecord::Base
  attr_accessible :central_id, :name, :volume
  
  has_many :ice_yields
  
  default_scope { order('id') }
  
  def best_ore
    ice_yields.max_by { |y| y.quantity }.ice_ore
  end
end
