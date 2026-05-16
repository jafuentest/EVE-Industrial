require 'rails_helper'

RSpec.describe Item, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:item)).to be_valid
  end

  describe 'associations' do
    skip { is_expected.to have_many(:industry_jobs) }
    it { is_expected.to have_many(:orders) }
  end

  describe '#save' do
    subject { item.save }

    let(:item) { FactoryBot.build(:item, name: nil) }
    let(:item_name) { "Item Name #{rand(10)}" }

    before do
      allow(ESI).to receive(:fetch_item_name).and_return(item_name)
    end

    it "Sets the item's name" do
      subject
      expect(item.name).to eq(item_name)
    end

    it "Call's ESI to fetch the item's name" do
      expect(ESI).to receive(:fetch_item_name).once
      subject
    end
  end

  describe '#create_items' do
    subject { described_class.create_items(item_ids) }

    let(:item_ids) { (1..2).to_a }

    before do
      allow(ESI).to receive(:fetch_item_name).and_return("Item Name #{rand(10)}")
    end

    it 'creates an item object for each id given' do
      subject
      expect(described_class.pluck(:id).sort).to eq(item_ids)
    end

    it 'does not create duplicates' do
      item_ids.each { |id| FactoryBot.create(:item, id:) }
      subject

      expect(described_class.count).to eq(item_ids.size)
    end
  end
end
