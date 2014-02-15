class Region < ActiveRecord::Base
  attr_accessible :central_id, :name
  
  has_many :systems
  
  default_scope { order('id') }
end
