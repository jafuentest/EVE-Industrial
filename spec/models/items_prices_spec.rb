require 'rails_helper'

RSpec.describe ItemsPrices, type: :model do
  before do
    allow(ESI).to receive(:fetch_item_name).and_return('Test Item')
  end

  it 'has a valid factory' do
    expect(FactoryBot.build(:items_prices)).to be_valid
  end

  describe '#save!' do
    subject(:save_instance) { instance.save! }

    context 'when instance is not persisted' do
      let(:instance) { FactoryBot.build(:items_prices) }

      it 'persists as a new record' do
        save_instance
        expect(instance).to be_persisted
      end

      it 'returns true' do
        expect(save_instance).to be(true)
      end
    end

    context 'when instance is already persisted' do
      let!(:instance) { FactoryBot.create(:items_prices) }
      let(:count) { described_class.count }
      let(:new_buy_price) { instance.buy_price + 10 }
      let(:new_sell_price) { instance.sell_price + 10 }
      before do
        instance.buy_price = new_buy_price
        instance.sell_price = new_sell_price
        save_instance
      end

      it 'updates buy price of existing record' do
        item_price = described_class.find_by(item_id: instance.item_id, star_id: instance.star_id)
        expect(item_price.buy_price).to eq(new_buy_price)
      end

      it 'updates sell price of existing record' do
        item_price = described_class.find_by(item_id: instance.item_id, star_id: instance.star_id)
        expect(item_price.sell_price).to eq(new_sell_price)
      end

      it 'does not create new records' do
        expect(described_class.count).to eq(count)
      end
    end

    it 'raises exception trying to create invalid record' do
      invalid_instance = described_class.new(star: nil, item: nil)
      expect { invalid_instance.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
