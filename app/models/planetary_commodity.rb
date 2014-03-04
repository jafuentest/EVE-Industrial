class PlanetaryCommodity < ActiveRecord::Base
  attr_accessible :central_id, :name, :quantity, :tier, :volume
  
  has_one :schematic, :foreign_key => :input_id
  has_many :schematics, :foreign_key => :output_id
  has_many :requirements, :through => :schematics, :source => :output
  
  def processing_revenue(prices)
    raw_gain = 0
    processing_gain = prices[central_id] * quantity
    schematics.each do |schematic|
      raw_gain += prices[schematic.input.central_id] * schematic.quantity
    end
    ((processing_gain - raw_gain) / raw_gain) * 100
  end
end
