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

  def hash_from_csv_row
    {
      id: row['ID'],
      name: row['Name'],
      tier: row['Tier'],
      volume: row['volume'],
      batch_size: row['Batch Size']
    }
  end
end
