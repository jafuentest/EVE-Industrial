require 'rails_helper'

RSpec.describe Star, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:star)).to be_valid
  end

  describe '#hash_from_csv_row' do
    it 'returns a hash representation of a star from a CSV row' do
      csv_row = {
        'ID' => 30000142,
        'Name' => 'Jita',
        'Constellation ID' => 20000020,
        'Region ID' => 10000002
      }
      expected_hash = {
        id: csv_row['ID'],
        name: csv_row['Name'],
        constellation_id: csv_row['Constellation ID'],
        region_id: csv_row['Region ID']
      }

      expect(Star.hash_from_csv_row(csv_row)).to eq(expected_hash)
    end
  end
end
