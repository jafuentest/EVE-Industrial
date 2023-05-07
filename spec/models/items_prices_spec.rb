require 'rails_helper'

RSpec.describe ItemsPrices, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:items_prices)).to be_valid
  end

  describe '#save!' do
    it 'persists a valid new record' do
      item_price = FactoryBot.build(:items_prices)
      expect(item_price.save!).to eq(true)
      expect(item_price).to be_persisted
    end

    it 'updates prices of existing record' do
      item_price = FactoryBot.create(:items_prices)
      count = ItemsPrices.count
      new_buy_price = item_price.buy_price = item_price.buy_price + 10
      new_sell_price = item_price.sell_price = item_price.sell_price + 10

      item_price.save!
      item_price = ItemsPrices.find_by(item_id: item_price.item_id, star_id: item_price.star_id)

      expect(ItemsPrices.count).to eq(count)
      expect(item_price.buy_price).to eq(new_buy_price)
      expect(item_price.sell_price).to eq(new_sell_price)
    end

    it 'raises exception trying to create invalid record' do
      expect {
        ItemsPrices.new(star: nil, item: nil).save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
