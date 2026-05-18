require 'rails_helper'

RSpec.describe PlanetaryColony, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:planetary_colony)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:character) }
  end

  describe '#extractors' do
    let(:colony) { FactoryBot.build(:planetary_colony, extractors:) }
    let(:extractors) do
      [{ 'expiry_time' => '2026-05-20T12:00:00Z', 'extractor_details' => { 'cycle_time' => 3600 } }]
    end

    it 'parses the stored JSON' do
      expect(colony.extractors).to eq(extractors)
    end

    it 'returns entries with indifferent access' do
      expect(colony.extractors.first[:expiry_time]).to eq('2026-05-20T12:00:00Z')
    end
  end

  describe '#factories' do
    let(:factories) { [{ 'type_id' => 2473, 'schematic_id' => 65 }] }
    let(:colony) { FactoryBot.build(:planetary_colony, factories:) }

    it 'parses the stored JSON' do
      expect(colony.factories).to eq(factories)
    end

    it 'returns entries with indifferent access' do
      expect(colony.factories.first[:schematic_id]).to eq(65)
    end
  end

  describe '#expiry_time' do
    context 'when extractors have expiry times' do
      let(:colony) { FactoryBot.build(:planetary_colony, extractors: extractors) }
      let(:extractors) do
        [
          { 'expiry_time' => '2026-05-20T12:00:00Z' },
          { 'expiry_time' => '2026-05-18T08:00:00Z' }
        ]
      end

      it 'returns the earliest expiry time' do
        expect(colony.expiry_time).to eq(Time.zone.parse('2026-05-18T08:00:00Z'))
      end
    end

    context 'when there are no extractors' do
      let(:colony) { FactoryBot.build(:planetary_colony, extractors: []) }

      it 'returns the current time' do
        freeze_time = Time.zone.parse('2026-05-16T10:00:00Z')
        allow(Time.zone).to receive(:now).and_return(freeze_time)
        expect(colony.expiry_time).to eq(freeze_time)
      end
    end
  end

  describe '#isk_per_day' do
    subject(:isk_per_day) { colony.isk_per_day }

    let(:star) { FactoryBot.create(:star, id: 30_000_142) }
    let(:commodity) { FactoryBot.create(:planetary_commodity, tier: 1, batch_size: 3000, schematic_id: 65) }
    let(:colony) { FactoryBot.build(:planetary_colony, factories: factories) }
    let(:factories) do
      [
        { 'type_id' => 2473, 'schematic_id' => 65 },
        { 'type_id' => 2473, 'schematic_id' => 65 }
      ]
    end

    before { FactoryBot.create(:items_prices, star:, item: commodity, buy_price: 500.0) }

    it 'sums the daily isk for each schematic grouped by count' do
      expected = 3000 * 2 * 2 * 500.0 * 24
      expect(isk_per_day).to eq(expected)
    end
  end

  describe '.update_character_colonies' do
    subject(:update) { described_class.update_character_colonies(character) }

    let(:character) { FactoryBot.create(:character) }
    let(:planet_details) do
      [
        {
          'last_update' => '2026-05-16T10:00:00Z',
          'planet_id' => 40_000_001,
          'planet_type' => 'barren',
          'star_id' => 30_000_142,
          'upgrade_level' => 4,
          'pins' => [
            {
              'type_id' => 2473,
              'schematic_id' => 65
            },
            {
              'expiry_time' => '2026-05-20T12:00:00Z',
              'extractor_details' => {
                'cycle_time' => 3600,
                'product_type_id' => 2268,
                'qty_per_cycle' => 100,
                'head_radius' => 0.5
              }
            }
          ]
        }
      ]
    end
    let(:expected_attributes) do
      {
        character_id: character.id,
        planet_id: 40_000_001,
        planet_type: 'barren',
        star_id: 30_000_142,
        upgrade_level: 4
      }
    end
    let(:expected_extractors) do
      [{
        'expiry_time' => '2026-05-20T12:00:00Z',
        'extractor_details' => { 'cycle_time' => 3600, 'product_type_id' => 2268, 'qty_per_cycle' => 100 }
      }]
    end

    before { allow(ESI).to receive(:fetch_planets_details).with(character).and_return(planet_details) }

    it 'creates a colony for the character' do
      expect { update }.to change(described_class, :count).by(1)
    end

    it 'persists the planet attributes' do
      update
      expect(described_class.last).to have_attributes(expected_attributes)
    end

    it 'stores the extractor details from the pins' do
      update
      expect(described_class.last.extractors).to eq(expected_extractors)
    end

    it 'stores the top level factories from the pins' do
      update
      expect(described_class.last.factories).to eq([{ 'type_id' => 2473, 'schematic_id' => 65 }])
    end

    it 'updates an existing colony instead of duplicating it' do
      update
      expect { described_class.update_character_colonies(character) }
        .not_to change(described_class, :count)
    end
  end
end
