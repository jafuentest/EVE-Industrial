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
      Net::HTTPOK.new("1.1", "200", "OK").tap do |resp|
        allow(resp).to receive(:body).and_return(body)
        resp["expires"] = "Mon, 02 Jun 2026 00:00:00 GMT"
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

    context "when the response has no expires header" do
      let(:response) do
        Net::HTTPOK.new("1.1", "200", "OK").tap { |resp| allow(resp).to receive(:body).and_return(body) }
      end

      it "omits expires_at" do
        expect(fetch_prices.first).not_to have_key("expires_at")
      end
    end

    context "when the request is not successful" do
      let(:response) do
        Net::HTTPInternalServerError.new("1.1", "500", "Error").tap do |resp|
          allow(resp).to receive(:body).and_return("error")
        end
      end

      it "skips the item instead of persisting bad data" do
        allow(Rails.logger).to receive(:warn)
        expect(fetch_prices).to be_empty
      end

      it "logs a warning" do
        allow(Rails.logger).to receive(:warn)
        fetch_prices
        expect(Rails.logger).to have_received(:warn).with(/EVE Tycoon price request failed \(500\)/)
      end
    end
  end
end
