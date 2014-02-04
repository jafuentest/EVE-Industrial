class Ore < ActiveRecord::Base
  attr_accessible :name, :refine, :volume
  has_many :variations
  has_many :ores_minerals
  has_many :minerals, through: :ores_minerals
  
  def refine_volume
    refine * volume
  end
end
