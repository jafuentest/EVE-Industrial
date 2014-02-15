# == Schema Information
#
# Table name: ores
#
#  id     :integer          not null, primary key
#  name   :string(255)
#  refine :integer
#  volume :float
#

class Ore < ActiveRecord::Base
  attr_accessible :name, :refine, :volume
  
  has_many :variations
  has_many :ores_minerals
  has_many :minerals, through: :ores_minerals
  
  default_scope { order('id') }
  
  def refine_volume
    refine * volume
  end
end
