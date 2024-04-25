require 'rails_helper'

RSpec.describe ItemsPrices, type: :model do
  before do
    allow(ESI).to receive(:fetch_item_name).and_return('Test Item')
  end

  it 'has a valid factory' do
    expect(FactoryBot.build(:items_prices)).to be_valid
  end

  describe '#save!' do
    subject { instance.save! }

    context 'when instance is not persisted' do
      let(:instance) { FactoryBot.build(:items_prices) }

      it 'persists as a new record' do
        subject
        expect(instance).to be_persisted
      end

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when instance is already persisted' do
      let!(:instance) { FactoryBot.create(:items_prices) }
      let(:count) { ItemsPrices.count }
      let(:new_buy_price) { instance.buy_price + 10 }
      let(:new_sell_price) { instance.sell_price + 10 }

      before do
        instance.buy_price = new_buy_price
        instance.sell_price = new_sell_price
      end

      it 'updates prices of existing record' do
        subject
        item_price = ItemsPrices.find_by(item_id: instance.item_id, star_id: instance.star_id)
        expect(item_price.buy_price).to eq(new_buy_price)
        expect(item_price.sell_price).to eq(new_sell_price)
      end

      it 'does not create new records' do
        subject
        expect(ItemsPrices.count).to eq(count)
      end
    end

    it 'raises exception trying to create invalid record' do
      invalid_instance = ItemsPrices.new(star: nil, item: nil)
      expect { invalid_instance.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
