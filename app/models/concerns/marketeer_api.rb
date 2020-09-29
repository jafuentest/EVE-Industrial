module MarketeerAPI
  extend ActiveSupport::Concern

  BASE_URL = 'https://api.evemarketer.com/ec/marketstat/json'

  class_methods do
    def fetch_prices_for(items:, star_id:)
      uri = request_uri(items, star_id)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end

    private

    def request_uri(items, star_id)
      url = "#{BASE_URL}?typeid=#{items.join(',')}&use_system=#{star_id}"
      URI(url)
    end
  end
end
