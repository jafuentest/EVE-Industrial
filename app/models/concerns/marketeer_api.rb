module MarketeerAPI
  require "net/http"

  extend ActiveSupport::Concern

  BASE_URL = "https://evetycoon.com/api/v1".freeze

  class_methods do
    def fetch_prices_for(items:, region_id: default_region)
      items.map do |item_id|
        uri = request_uri(item_id, region_id)
        response = Net::HTTP.get_response(uri)

        # TODO: Handle non-successful responses
        JSON.parse(response.body)
          .merge(expires_at_from_response(response))
          .merge("item_id" => item_id)
      end
    end

    private

    def expires_at_from_response(response)
      header_value = response.each_header.find { |e| e.first == "expires" }.last
      return {} unless header_value

      { "expires_at" => Time.httpdate(header_value) }
    end

    def default_region
      Region::IDs::THE_FORGE
    end

    def request_uri(item_id, region_id)
      url = "#{BASE_URL}/market/stats/#{region_id}/#{item_id}"
      URI(url)
    end
  end
end
