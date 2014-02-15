# == Schema Information
#
# Table name: ores_minerals
#
#  id         :integer          not null, primary key
#  ore_id     :integer
#  mineral_id :integer
#  share      :float
#

class OresMineral < ActiveRecord::Base
  attr_accessible :mineral_id, :ore_id, :share
  
  belongs_to :ore
  belongs_to :mineral
  
  default_scope { order('id') }
end
