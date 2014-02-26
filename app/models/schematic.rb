class Schematic < ActiveRecord::Base
  attr_accessible :input_id, :output_id, :quantity
  
  belongs_to :input, :class_name => :PlanetaryCommodity, :foreign_key => 'input_id'
  belongs_to :output, :class_name => :PlanetaryCommodity, :foreign_key => 'output_id'
end
