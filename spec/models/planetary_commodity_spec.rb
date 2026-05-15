require 'csv'
require 'rails_helper'

RSpec.describe PlanetaryCommodity, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:planetary_commodity)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:items_prices) }
  end

  it_behaves_like 'csv_importable' do
    before(:each) do
      commodity = FactoryBot.build(:planetary_commodity)
      csv_row = {
        'ID' => commodity.id,
        'Name' => commodity.name,
        'Tier' => commodity.tier,
        'Volume' => commodity.volume,
        'Batch Size' => commodity.batch_size
      }

      allow(CSV).to receive(:read).with(kind_of(String), headers: true)
        .and_return([csv_row])
    end
  end

  describe '.hash_from_csv_row' do
    let(:csv_row) do
      {
        'ID' => 2268,
        'Name' => 'Bacteria',
        'Tier' => 1,
        'Volume' => 0.01,
        'Batch Size' => 3000
      }
    end
    let(:expected_hash) do
      {
        id: csv_row['ID'],
        name: csv_row['Name'],
        tier: csv_row['Tier'],
        volume: csv_row['Volume'],
        batch_size: csv_row['Batch Size']
      }
    end

    it 'returns a hash representation of a planetary commodity from a CSV row' do
      expect(PlanetaryCommodity.hash_from_csv_row(csv_row)).to eq(expected_hash)
    end
  end

  describe '.update_prices' do
    let!(:star) { FactoryBot.create(:star) }

    it 'logs a warning for each star' do
      expect(Rails.logger).to receive(:warn).with('Eve Marketeer API no longer exists').once
      PlanetaryCommodity.update_prices
    end
  end

  describe '.price_list' do
    let(:star) { FactoryBot.create(:star) }
    let(:commodity) { FactoryBot.create(:planetary_commodity) }
    let!(:items_prices) { FactoryBot.create(:items_prices, star:, item: commodity) }

    subject { PlanetaryCommodity.price_list(star.id) }

    it 'returns commodities with prices for the given star' do
      expect(subject.map(&:id)).to include(commodity.id)
    end

    it 'includes buy and sell price columns' do
      result = subject.first
      expect(result).to respond_to(:buy_price)
      expect(result).to respond_to(:sell_price)
    end

    it 'orders results by name' do
      other = FactoryBot.create(:planetary_commodity, name: 'AAA Commodity')
      FactoryBot.create(:items_prices, star:, item: other)

      expect(subject.first.id).to eq(other.id)
    end
  end

  describe '.with_price' do
    let(:star) { FactoryBot.create(:star) }
    let(:commodity) { FactoryBot.create(:planetary_commodity) }
    let!(:items_prices) { FactoryBot.create(:items_prices, star:, item: commodity) }

    subject { PlanetaryCommodity.with_price(system_id: star.id) }

    it 'returns commodities with prices for the given star' do
      expect(subject.map(&:id)).to include(commodity.id)
    end

    context 'when query params are given' do
      it 'filters by the given params' do
        result = PlanetaryCommodity.with_price(system_id: star.id, id: commodity.id)
        expect(result.id).to eq(commodity.id)
      end

      it 'returns nil when no match' do
        result = PlanetaryCommodity.with_price(system_id: star.id, id: -1)
        expect(result).to be_nil
      end
    end
  end

  describe '#cycles_per_hour' do
    it 'returns 2 for tier 1' do
      commodity = FactoryBot.build(:planetary_commodity, tier: 1)
      expect(commodity.cycles_per_hour).to eq(2)
    end

    it 'returns 1 for tiers above 1' do
      commodity = FactoryBot.build(:planetary_commodity, tier: 2)
      expect(commodity.cycles_per_hour).to eq(1)
    end
  end

  describe '#isk_per_hour' do
    let(:buy_price) { 500.0 }
    let(:sell_price) { 600.0 }
    let(:factories) { 2 }
    let(:star) { FactoryBot.create(:star) }
    let(:base_commodity) { FactoryBot.create(:planetary_commodity, tier: 1, batch_size: 3000) }
    let!(:items_prices) { FactoryBot.create(:items_prices, star:, item: base_commodity, buy_price:, sell_price:) }
    let(:commodity) { PlanetaryCommodity.with_price(system_id: star.id, id: base_commodity.id) }

    it 'calculates isk per hour using buy price by default' do
      expected = 3000 * factories * commodity.cycles_per_hour * buy_price
      expect(commodity.isk_per_hour(factories)).to eq(expected)
    end

    it 'calculates isk per hour using sell price when specified' do
      expected = 3000 * factories * commodity.cycles_per_hour * sell_price
      expect(commodity.isk_per_hour(factories, :sell)).to eq(expected)
    end
  end
end
