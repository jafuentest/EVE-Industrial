require 'rails_helper'

RSpec.describe ESI do
  let(:character) { FactoryBot.build(:character) }

  def http_response(body, success: true)
    klass = success ? Net::HTTPOK : Net::HTTPInternalServerError
    klass.new('1.1', success ? '200' : '500', success ? 'OK' : 'Error').tap do |res|
      allow(res).to receive(:body).and_return(body)
    end
  end

  describe '.authenticate' do
    subject(:authenticate) { described_class.authenticate('auth_code') }

    let(:token_payload) do
      { 'access_token' => 'access', 'refresh_token' => 'refresh', 'expires_in' => 1199 }
    end

    context 'when the request succeeds' do
      before do
        allow(Net::HTTP).to receive(:start).and_return(http_response(token_payload.to_json))
      end

      it 'returns the parsed token payload' do
        expect(authenticate).to eq(token_payload)
      end
    end

    context 'when the request fails' do
      before do
        allow(Net::HTTP).to receive(:start).and_return(http_response('error', success: false))
      end

      it 'returns nil' do
        expect(authenticate).to be_nil
      end
    end

    context 'when refreshing the token' do
      before do
        allow(Net::HTTP).to receive(:start).and_return(http_response(token_payload.to_json))
      end

      it 'returns the parsed token payload' do
        expect(described_class.authenticate('refresh_token', refresh: true)).to eq(token_payload)
      end
    end
  end

  describe '.verify_access_token' do
    subject(:verify) { described_class.verify_access_token('access_token') }

    let(:verification) { { 'CharacterID' => 123, 'CharacterName' => 'Pilot' } }

    before do
      allow(Net::HTTP).to receive(:start).and_return(http_response(verification.to_json))
    end

    it 'returns the parsed verification data' do
      expect(verify).to eq(verification)
    end
  end

  describe '.fetch_item_name' do
    subject(:fetch_item_name) { described_class.fetch_item_name(34) }

    before do
      allow(Net::HTTP).to receive(:start).and_return(http_response({ 'name' => 'Tritanium' }.to_json))
    end

    it 'returns the item name' do
      expect(fetch_item_name).to eq('Tritanium')
    end
  end

  describe '.fetch_character_market_orders' do
    subject(:fetch_orders) { described_class.fetch_character_market_orders(character) }

    let(:orders) { [{ 'order_id' => 1 }, { 'order_id' => 2 }] }

    before do
      allow(Net::HTTP).to receive(:start).and_return(http_response(orders.to_json))
    end

    it 'returns the parsed orders' do
      expect(fetch_orders).to eq(orders)
    end
  end

  describe '.fetch_citadel_orders' do
    subject(:fetch_citadel_orders) { described_class.fetch_citadel_orders(character, 1_000_000, 1) }

    context 'when the response is an array' do
      let(:orders) { [{ 'order_id' => 1 }] }

      before do
        allow(Net::HTTP).to receive(:start).and_return(http_response(orders.to_json))
      end

      it 'returns the orders' do
        expect(fetch_citadel_orders).to eq(orders)
      end
    end

    context 'when the response is not an array' do
      before do
        allow(Net::HTTP).to receive(:start).and_return(http_response({ 'error' => 'forbidden' }.to_json))
      end

      it 'returns nil' do
        expect(fetch_citadel_orders).to be_nil
      end
    end
  end

  describe '.fetch_region_orders' do
    subject(:fetch_region_orders) { described_class.fetch_region_orders(10_000_002, 34, 'sell') }

    context 'when the response is an array' do
      let(:orders) { [{ 'price' => 5.0 }] }

      before do
        allow(Net::HTTP).to receive(:start).and_return(http_response(orders.to_json))
      end

      it 'returns the orders' do
        expect(fetch_region_orders).to eq(orders)
      end
    end

    context 'when the response is not an array' do
      before do
        allow(Net::HTTP).to receive(:start).and_return(http_response({ 'error' => 'bad request' }.to_json))
      end

      it 'returns nil' do
        expect(fetch_region_orders).to be_nil
      end
    end
  end

  describe '.fetch_character_industry_jobs' do
    subject(:fetch_jobs) { described_class.fetch_character_industry_jobs(character) }

    let(:jobs) { [{ 'job_id' => 1 }] }

    before do
      allow(Net::HTTP).to receive(:start).and_return(http_response(jobs.to_json))
    end

    it 'returns the parsed jobs' do
      expect(fetch_jobs).to eq(jobs)
    end
  end

  describe '.fetch_planets_details' do
    subject(:fetch_planets_details) { described_class.fetch_planets_details(character) }

    let(:planets) { [{ 'planet_id' => 40, 'solar_system_id' => 30 }] }
    let(:planet_details) { { 'links' => [], 'pins' => [] } }

    before do
      allow(Net::HTTP).to receive(:start).and_return(
        http_response(planets.to_json),
        http_response(planet_details.to_json)
      )
    end

    it 'renames solar_system_id to star_id and merges the planet details' do
      expect(fetch_planets_details).to eq(
        [{ 'planet_id' => 40, 'star_id' => 30, 'links' => [], 'pins' => [] }]
      )
    end
  end

  describe '.fetch_character_portrait' do
    let(:portrait) { { 'px64x64' => 'https://images/64.jpg' } }

    before do
      allow(Net::HTTP).to receive(:start).and_return(http_response(portrait.to_json))
    end

    context 'when given a Character' do
      it 'returns the parsed portrait data' do
        expect(described_class.fetch_character_portrait(character)).to eq(portrait)
      end
    end

    context 'when given a character id' do
      it 'returns the parsed portrait data' do
        expect(described_class.fetch_character_portrait(123)).to eq(portrait)
      end
    end
  end
end
