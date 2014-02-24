# == Schema Information
#
# Table name: systems
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  central_id :integer
#  region_id  :integer
#  security   :float
#

class System < ActiveRecord::Base
  attr_accessible :central_id, :name, :region_id, :security
  
  belongs_to :region
  
  self.per_page = 20
end
