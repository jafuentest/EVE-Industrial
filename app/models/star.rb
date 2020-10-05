# == Schema Information
#
# Table name: stars
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  constellation_id :integer          not null
#  region_id        :integer          not null
#
class Star < ApplicationRecord
  include CSVImportable

  self.primary_key = :id

  def self.hash_from_csv_row(row)
    {
      id: row['ID'],
      name: row['Name'],
      constellation_id: row['Constellation ID'],
      region_id: row['Region ID']
    }
  end
end
