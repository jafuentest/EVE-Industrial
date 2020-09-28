# == Schema Information
#
# Table name: planetary_commodities
#
#  id         :integer          not null
#  name       :string
#  tier       :integer
#  volume     :decimal(5, 2)
#  batch_size :integer
#  input      :text
#
class PlanetaryCommodity < ApplicationRecord
end
