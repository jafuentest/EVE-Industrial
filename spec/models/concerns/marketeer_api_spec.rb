require "rails_helper"

RSpec.describe MarketeerAPI, type: :model do
  let(:dummy_class) do
    Class.new do
      include MarketeerAPI
    end
  end

  describe ".fetch_prices_for" do
    subject(:fetch_prices) { dummy_class.fetch_prices_for(items:, region_id:) }

    let(:items) { [34] }
    let(:region_id) { Region::IDs::THE_FORGE }
    let(:body) { { "buyAvgFivePercent" => 5.0, "sellAvgFivePercent" => 7.0 }.to_json }
    let(:response) do
      instance_double(Net::HTTPResponse, body:).tap do |resp|
        allow(resp).to receive(:each_header).and_return([["expires", "Mon, 02 Jun 2026 00:00:00 GMT"]])
      end
    end

    before { allow(Net::HTTP).to receive(:get_response).and_return(response) }

    it "requests the region/item endpoint from EVE Tycoon" do
      fetch_prices
      expect(Net::HTTP).to have_received(:get_response)
        .with(URI("https://evetycoon.com/api/v1/market/stats/#{region_id}/34"))
    end

    it "returns parsed price data tagged with the item id" do
      expect(fetch_prices).to contain_exactly(
        hash_including("item_id" => 34, "buyAvgFivePercent" => 5.0, "sellAvgFivePercent" => 7.0)
      )
    end

    it "includes the expiry parsed from the response headers" do
      expect(fetch_prices.first["expires_at"]).to eq(Time.httpdate("Mon, 02 Jun 2026 00:00:00 GMT"))
    end
  end
end
