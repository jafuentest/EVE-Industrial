# == Schema Information
#
# Table name: regions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  central_id :integer
#

class Region < ActiveRecord::Base
  attr_accessible :central_id, :name
  
  has_many :systems
  
  default_scope { order('name') }
end
