class Mineral < ActiveRecord::Base
  attr_accessible :name, :volume, :central_id, :ore_id
  has_many :yields
  has_many :ores_minerals
  has_many :ores, through: :ores_minerals
  
  def best_ore
    yields.max_by { |x| x.material_yield }.variation
  end
end
