class IceProduct < ActiveRecord::Base
  attr_accessible :central_id, :name, :volume
  
  has_many :ice_yields
  
  default_scope { order('id') }
end
