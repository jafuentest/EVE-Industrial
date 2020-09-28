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
  include CSVImportable

  self.primary_key = :id

  def self.hash_from_csv_row(row)
    {
      id: row['ID'],
      name: row['Name'],
      tier: row['Tier'],
      volume: row['Volume'],
      batch_size: row['Batch Size']
    }
  end
end
