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


    it 'raises exception trying to create invalid record' do
      invalid_instance = described_class.new(star: nil, item: nil)
      expect { invalid_instance.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
