require 'rails_helper'

RSpec.describe MarketeerAPI, type: :model do
  let(:dummy_class) do
    Class.new do
      include MarketeerAPI
    end
  end

  describe '.fetch_prices_for' do
    subject(:fetch_prices) { dummy_class.fetch_prices_for(items:, star_id:) }

    let(:items) { [FactoryBot.create(:item)].map(&:id) }
    let(:star_id) { FactoryBot.create(:star).id }

    it 'raises an error' do
      error_message = 'Eve Marketeer API no longer exists, request: ' \
                      'https://api.evemarketer.com/ec/marketstat/json?' \
                      "typeid=#{items.join(',')}&usesystem=#{star_id}"

      expect { fetch_prices }.to raise_error(RuntimeError, error_message)
    end
  end
end
