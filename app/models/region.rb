class Region < ActiveRecord::Base
  attr_accessible :central_id, :name
  
  has_many :systems
end
