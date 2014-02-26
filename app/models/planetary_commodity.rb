class PlanetaryCommodity < ActiveRecord::Base
  attr_accessible :central_id, :name, :quantity, :tier, :volume
  
  has_many :schematics, :foreign_key => :output_id
  has_many :requirements, :through => :schematics, :source => :input
end
