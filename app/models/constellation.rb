class Constellation < ApplicationRecord
  self.primary_key = :id

  belongs_to :region
  has_many :stars
end
