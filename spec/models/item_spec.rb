require 'rails_helper'

RSpec.describe Item, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:item)).to be_valid
  end

  describe '#set_name' do
    it "calls the ESI to set the item's name" do
      star_name = SecureRandom.alphanumeric
      allow(ESI).to receive(:fetch_item_name).and_return(star_name)
      star = FactoryBot.build(:item, name: nil)
      star.set_name

      expect(star.name).to eq(star_name)
    end
  end

  describe '#create_items' do
    let(:test_items) { 2 }
    before(:each) do
      expect(ESI).to receive(:fetch_item_name).twice
        .and_return(SecureRandom.alphanumeric)
    end

    it 'creates an item object for each id given' do
      item_ids = (1..test_items).to_a
      Item.destroy_all
      Item.create_items(item_ids)

      expect(Item.count).to eq(item_ids.size)
      expect(Item.pluck(:id).sort).to eq(item_ids)
    end

    it 'does not try to create duplicates' do
      item_ids = (1..test_items).to_a
      FactoryBot.create(:item, id: 1)
      FactoryBot.create(:item, id: 2)
      Item.create_items(item_ids)

      expect(Item.count).to eq(item_ids.size)
      expect(Item.pluck(:id).sort).to eq(item_ids)
    end
  end
end
