# == Schema Information
#
# Table name: minerals
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  volume     :string(255)
#  central_id :integer
#

class Mineral < ActiveRecord::Base
  attr_accessible :central_id, :name, :ore_id
  
  has_many :yields
  has_many :ores_minerals
  has_many :ores, through: :ores_minerals
  
  default_scope { order('id') }
  
  VOLUME = 0.01
  
  def best_ore
    yields.max_by { |y| y.base_yield }.variation.ore
  end
end
