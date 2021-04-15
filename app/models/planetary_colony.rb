class PlanetaryColony < ApplicationRecord
  belongs_to :character

  def extractors
    JSON.parse(self[:extractors]).with_indifferent_access
  end

  def extractors=(o)
    self[:extractors] = o.to_json
  end

  def factories
    JSON.parse(self[:factories]).with_indifferent_access
  end

  def factories=(o)
    self[:factories] = o.to_json
  end
end
