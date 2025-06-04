module MarketeerAPI
  extend ActiveSupport::Concern

  BASE_URL = 'https://api.evemarketer.com/ec/marketstat/json'.freeze

  class_methods do
    def fetch_prices_for(items:, star_id:)
      raise "Eve Marketeer API no longer exists, request: #{request_uri(items, star_id)}"
    end

    private

    def request_uri(items, star_id)
      url = "#{BASE_URL}?typeid=#{items.join(',')}&usesystem=#{star_id}"
      URI(url)
    end
  end
end
