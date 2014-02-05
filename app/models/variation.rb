class Variation < ActiveRecord::Base
  attr_accessible :name, :bonus, :ore_id, :central_id
  belongs_to :ore
  has_many :yields

  def name
    if self[:name].nil? || self[:name].empty?
      ore.name
    else
      self[:name] + ' ' + ore.name
    end
  end
  
  def refine_volume
    ore.refine_volume
  end
end
