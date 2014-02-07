# == Schema Information
#
# Table name: variations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  ore_id     :integer
#  bonus      :integer
#  central_id :integer
#

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
  
  def volume
    ore.volume
  end
  
  def refine_ammount
    ore.refine
  end
  
  def refine_volume
    ore.refine_volume
  end
  
  def raw_revenue(price, sale_tax)
    (price * sale_tax) / volume
  end
  
  def refine_revenue(refining_yield, price_list, sale_tax)
    revenue = 0
    if yields.size != 0
      yields.each do |y|
        price = price_list[y.mineral.central_id]
        revenue += y.quantity * price
      end
    end
    (revenue / refine_ammount) / volume
  end
end
