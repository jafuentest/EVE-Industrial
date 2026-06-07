module EveTycoonAPI
  require "net/http"

  extend ActiveSupport::Concern

  BASE_URL = "https://evetycoon.com/api/v1".freeze

  class_methods do
    def fetch_prices_for(items:, region_id: default_region)
      items.filter_map { |item_id| price_data_for(item_id, region_id) }
    end

    private

    def price_data_for(item_id, region_id)
      uri = request_uri(item_id, region_id)
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.warn("EVE Tycoon price request failed (#{response.code}) for #{uri}")
        return nil
      end

      JSON.parse(response.body)
        .merge(expires_at_from_response(response))
        .merge("item_id" => item_id)
    end

    def expires_at_from_response(response)
      return {} unless response["expires"]

      { "expires_at" => Time.httpdate(response["expires"]) }
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
