class Region < ApplicationRecord
  self.primary_key = :id

  has_many :constellations
  has_many :stars
end
