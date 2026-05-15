require 'csv'
require 'rails_helper'

RSpec.describe Star, type: :model do
  it_behaves_like 'csv_importable' do
    before(:each) do
      star = FactoryBot.build(:star)
      star.constellation.save!
      csv_row = {
        'ID' => star.id,
        'Name' => star.name,
        'Constellation ID' => star.constellation_id,
        'Region ID' => star.region_id
      }

      allow(CSV).to receive(:read).with(kind_of(String), headers: true)
        .and_return([csv_row])
    end
  end

  it 'has a valid factory' do
    expect(FactoryBot.build(:star)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:constellation).required }
    it { is_expected.to belong_to(:region).required }
  end

  describe '#hash_from_csv_row' do
    let(:csv_row) do
      {
        'ID' => 30_000_142,
        'Name' => 'Jita',
        'Constellation ID' => 20_000_020,
        'Region ID' => 10_000_002
      }
    end
    let(:expected_hash) do
      {
        id: csv_row['ID'],
        name: csv_row['Name'],
        constellation_id: csv_row['Constellation ID'],
        region_id: csv_row['Region ID']
      }
    end

    it 'returns a hash representation of a star from a CSV row' do
      expect(Star.hash_from_csv_row(csv_row)).to eq(expected_hash)
    end
  end
end
