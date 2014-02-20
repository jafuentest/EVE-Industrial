class System < ActiveRecord::Base
  attr_accessible :central_id, :name, :region_id, :security
  
  belongs_to :region
  
  self.per_page = 20
end
