class Region < ApplicationRecord
  self.primary_key = :id

  has_many :constellations, dependent: :destroy
  has_many :stars, dependent: :destroy
end
