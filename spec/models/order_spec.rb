require 'rails_helper'

RSpec.describe Order, type: :model do
  before { allow(ESI).to receive(:fetch_item_name).and_return('Tritanium') }

  it 'has a valid factory' do
    expect(FactoryBot.build(:order)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:item) }
    it { is_expected.to belong_to(:character).optional }
  end

  describe '.npc_station?' do
    it 'returns true for ids below the NPC threshold' do
      expect(described_class.npc_station?(60_003_760)).to be(true)
    end

    it 'returns false for ids at or above the NPC threshold' do
      expect(described_class.npc_station?(100_000_001)).to be(false)
    end
  end

  describe '#market_diff' do
    let(:item) { FactoryBot.create(:item) }
    let(:region) { FactoryBot.create(:region) }

    context 'when it is a sell order in an NPC station' do
      let(:order) { FactoryBot.create(:order, item:, region:, buy_order: false, price: 100.0) }

      before { FactoryBot.create(:order, item:, region:, buy_order: false, price: 80.0) }

      it 'returns the gap to the cheapest competing price' do
        expect(order.market_diff).to eq(-20)
      end
    end

    context 'when it is a buy order in an NPC station' do
      let(:order) { FactoryBot.create(:order, item:, region:, buy_order: true, price: 100.0) }

      before { FactoryBot.create(:order, item:, region:, buy_order: true, price: 120.0) }

      it 'returns the gap to the highest competing price' do
        expect(order.market_diff).to eq(-20)
      end
    end

    context 'when it is placed in a citadel' do
      let(:order) { FactoryBot.create(:order, item:, location_id: 100_000_001, buy_order: false, price: 100.0) }

      before do
        FactoryBot.create(:order, item:, location_id: 100_000_001, buy_order: false, price: 70.0)
      end

      it 'delegates to the citadel market comparison' do
        expect(order.market_diff).to eq(-30)
      end
    end
  end

  describe '#market_diff_citadel' do
    let(:item) { FactoryBot.create(:item) }
    let(:order) { FactoryBot.create(:order, item:, location_id: 100_000_001, buy_order: false, price: 100.0) }

    before do
      FactoryBot.create(:order, item:, location_id: 100_000_001, buy_order: false, price: 90.0)
    end

    it 'compares against orders in the same structure' do
      expect(order.market_diff_citadel).to eq(-10)
    end
  end

  describe '.update_character_orders' do
    subject(:update) { described_class.update_character_orders(character, update_competition:) }

    let(:character) { FactoryBot.create(:character) }
    let(:update_competition) { false }
    let(:esi_orders) do
      [{
        'order_id' => 123,
        'type_id' => 34,
        'location_id' => 60_003_760,
        'region_id' => 10_000_002,
        'price' => 5.5,
        'issued' => '2026-05-16T10:00:00Z',
        'duration' => 90,
        'volume_remain' => 100,
        'volume_total' => 100,
        'is_buy_order' => false
      }]
    end

    before do
      FactoryBot.create(:region, id: 10_000_002)
      allow(ESI).to receive(:fetch_character_market_orders).with(character).and_return(esi_orders)
    end

    it 'creates an order from the ESI data' do
      expect { update }.to change(described_class, :count).by(1)
    end

    it 'stores the esi order id and character' do
      update
      expect(described_class.last).to have_attributes(esi_id: 123, character_id: character.id, price: 5.5)
    end

    context 'when update_competition is true' do
      let(:update_competition) { true }

      before { allow(ESI).to receive(:fetch_region_orders).and_return([]) }

      it 'fetches competing region orders' do
        update
        expect(ESI).to have_received(:fetch_region_orders).with(10_000_002, 34, 'all')
      end

      it 'destroys stale orders in the same region' do
        stale = FactoryBot.create(:order, region_id: 10_000_002, updated_at: 1.day.ago)
        update
        expect(described_class.exists?(stale.id)).to be(false)
      end

      it 'keeps the freshly upserted order' do
        update
        expect(described_class.find_by(esi_id: 123)).to be_present
      end
    end

    context 'when update_competition is true and the order is in a citadel' do
      let(:update_competition) { true }
      let(:esi_orders) do
        [{
          'order_id' => 123,
          'type_id' => 34,
          'location_id' => 100_000_001,
          'region_id' => 10_000_002,
          'price' => 5.5,
          'issued' => '2026-05-16T10:00:00Z',
          'duration' => 90,
          'volume_remain' => 100,
          'volume_total' => 100,
          'is_buy_order' => false
        }]
      end

      before { allow(ESI).to receive(:fetch_citadel_orders).and_return([]) }

      it 'destroys stale orders in the same structure' do
        stale = FactoryBot.create(:order, location_id: 100_000_001, updated_at: 1.day.ago)
        update
        expect(described_class.exists?(stale.id)).to be(false)
      end
    end
  end

  describe '.update_competing_orders' do
    let(:character) { FactoryBot.create(:character) }

    before { FactoryBot.create(:region, id: 10_000_002) }

    context 'when the location is an NPC station' do
      let(:orders) { [{ 'location_id' => 60_003_760, 'region_id' => 10_000_002, 'type_id' => 34 }] }

      before { allow(ESI).to receive(:fetch_region_orders).and_return([]) }

      it 'fetches competing region orders' do
        described_class.update_competing_orders(orders, character)
        expect(ESI).to have_received(:fetch_region_orders).with(10_000_002, 34, 'all')
      end
    end

    context 'when an NPC-station order is in a tracked system' do
      let(:orders) { [{ 'location_id' => 60_003_760, 'region_id' => 10_000_002, 'type_id' => 34 }] }
      let(:region_order) do
        {
          'order_id' => 777,
          'type_id' => 34,
          'system_id' => 30_000_142,
          'location_id' => 60_003_760,
          'price' => 9.9,
          'issued' => '2026-05-16T10:00:00Z',
          'duration' => 90,
          'volume_remain' => 50,
          'volume_total' => 50,
          'is_buy_order' => false
        }
      end

      before { allow(ESI).to receive(:fetch_region_orders).and_return([region_order]) }

      it 'upserts the competing order' do
        described_class.update_competing_orders(orders, character)
        expect(described_class.find_by(esi_id: 777)).to have_attributes(region_id: 10_000_002, price: 9.9)
      end
    end

    context 'when the location is a citadel' do
      let(:orders) { [{ 'location_id' => 100_000_001, 'region_id' => 10_000_002, 'type_id' => 34 }] }

      before { allow(ESI).to receive(:fetch_citadel_orders).and_return(nil) }

      it 'fetches competing citadel orders' do
        described_class.update_competing_orders(orders, character)
        expect(ESI).to have_received(:fetch_citadel_orders).with(character, 100_000_001, 1)
      end
    end

    context 'when the citadel structure returns orders' do
      let(:orders) { [{ 'location_id' => 100_000_001, 'region_id' => 10_000_002, 'type_id' => 34 }] }
      let(:citadel_order) do
        {
          'order_id' => 888,
          'type_id' => 34,
          'location_id' => 100_000_001,
          'price' => 12.0,
          'issued' => '2026-05-16T10:00:00Z',
          'duration' => 90,
          'volume_remain' => 7,
          'volume_total' => 7,
          'is_buy_order' => false
        }
      end

      before do
        allow(ESI).to receive(:fetch_citadel_orders)
          .with(character, 100_000_001, 1).and_return([citadel_order])
        allow(ESI).to receive(:fetch_citadel_orders)
          .with(character, 100_000_001, 2).and_return([])
      end

      it 'upserts the orders matching the tracked items' do
        described_class.update_competing_orders(orders, character)
        expect(described_class.find_by(esi_id: 888)).to have_attributes(price: 12.0, region_id: 10_000_002)
      end
    end
  end
end
