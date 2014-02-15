class System < ActiveRecord::Base
  attr_accessible :central_id, :name, :region_id, :security
  
  belongs_to :region
  
  default_scope { order('name') }
end
