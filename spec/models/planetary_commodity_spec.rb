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
    before do
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
      expect(described_class.hash_from_csv_row(csv_row)).to eq(expected_hash)
    end
  end

  describe '.update_prices' do
    let(:commodity) { FactoryBot.create(:planetary_commodity) }
    let(:jita) { FactoryBot.create(:star, id: Star::IDs::JITA) }
    let(:price_result) do
      { 'item_id' => commodity.id, 'buyAvgFivePercent' => 5.0, 'sellAvgFivePercent' => 7.0 }
    end

    before do
      jita
      commodity
      allow(described_class).to receive(:fetch_prices_for).and_return([price_result])
    end

    it 'fetches prices for Jita using its region' do
      described_class.update_prices
      expect(described_class).to have_received(:fetch_prices_for)
        .with(region_id: jita.region_id, items: [commodity.id])
    end

    it 'persists the fetched prices for the star' do
      described_class.update_prices
      expect(ItemsPrices.find_by(star_id: jita.id, item_id: commodity.id))
        .to have_attributes(buy_price: 5.0, sell_price: 7.0)
    end
  end

  describe '.price_list' do
    subject(:price_list) { described_class.price_list(star.id) }

    let(:star) { FactoryBot.create(:star) }
    let(:commodity) { FactoryBot.create(:planetary_commodity) }

    before { FactoryBot.create(:items_prices, star:, item: commodity) }

    it 'returns commodities with prices for the given star' do
      expect(price_list.map(&:id)).to include(commodity.id)
    end

    it 'includes buy_price column' do
      expect(price_list.first).to respond_to(:buy_price)
    end

    it 'includes sell_price column' do
      expect(price_list.first).to respond_to(:sell_price)
    end

    it 'orders results by name' do
      other = FactoryBot.create(:planetary_commodity, name: 'AAA Commodity')
      FactoryBot.create(:items_prices, star:, item: other)

      expect(price_list.first.id).to eq(other.id)
    end
  end

  describe '.with_price' do
    subject(:commodities_with_price) { described_class.with_price(system_id: star.id) }

    let(:star) { FactoryBot.create(:star) }
    let(:commodity) { FactoryBot.create(:planetary_commodity) }

    before { FactoryBot.create(:items_prices, star:, item: commodity) }

    it 'returns commodities with prices for the given star' do
      expect(commodities_with_price.map(&:id)).to include(commodity.id)
    end

    context 'when query params are given' do
      it 'filters by the given params' do
        result = described_class.with_price(system_id: star.id, id: commodity.id)
        expect(result.id).to eq(commodity.id)
      end

      it 'returns nil when no match' do
        result = described_class.with_price(system_id: star.id, id: -1)
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

  describe '#isk_per_hour' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:buy_price) { 500.0 }
    let(:sell_price) { 600.0 }
    let(:factories) { 2 }
    let(:star) { FactoryBot.create(:star) }
    let(:base_commodity) { FactoryBot.create(:planetary_commodity, tier: 1, batch_size: 3000) }
    let(:commodity) { described_class.with_price(system_id: star.id, id: base_commodity.id) }

    before { FactoryBot.create(:items_prices, star:, item: base_commodity, buy_price:, sell_price:) }

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
