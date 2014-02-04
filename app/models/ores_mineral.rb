class OresMineral < ActiveRecord::Base
  attr_accessible :mineral_id, :ore_id, :share
  belongs_to :ore
  belongs_to :mineral
end
