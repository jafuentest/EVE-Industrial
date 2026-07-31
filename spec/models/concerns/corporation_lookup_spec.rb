require "rails_helper"

RSpec.describe CorporationLookup, type: :model do
  let(:dummy_class) do
    Class.new do
      include CorporationLookup

      attr_reader :character_id

      def initialize(character_id)
        @character_id = character_id
      end
    end
  end

  let(:record) { dummy_class.new(90_000_001) }

  describe "#corporation_name" do
    subject(:corporation_name) { record.corporation_name }

    context "when ESI resolves the character's corporation" do
      before do
        allow(ESI).to receive_messages(
          fetch_character_details: { "corporation_id" => 98_000_001 },
          fetch_corporation_details: { "name" => "Test Corporation" }
        )
      end

      it "returns the corporation name" do
        expect(corporation_name).to eq("Test Corporation")
      end
    end

    context "when the record has no character_id" do
      let(:record) { dummy_class.new(nil) }

      before { allow(ESI).to receive(:fetch_character_details) }

      it "returns an empty string" do
        expect(corporation_name).to eq("")
      end
    end

    context "when the character has no corporation id" do
      before do
        allow(ESI).to receive(:fetch_character_details).and_return({ "corporation_id" => nil })
        allow(ESI).to receive(:fetch_corporation_details)
      end

      it "returns an empty string" do
        expect(corporation_name).to eq("")
      end
    end

    context "when ESI raises" do
      before do
        allow(ESI).to receive(:fetch_character_details).and_raise(StandardError, "boom")
        allow(Rails.logger).to receive(:warn)
      end

      it "returns an empty string rather than propagating the error" do
        expect(corporation_name).to eq("")
      end

      it "logs a warning" do
        corporation_name
        expect(Rails.logger).to have_received(:warn).with(/ESI corporation lookup failed/)
      end
    end

    context "when caching is enabled" do
      before do
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
        allow(ESI).to receive_messages(
          fetch_character_details: { "corporation_id" => 98_000_001 },
          fetch_corporation_details: { "name" => "Test Corporation" }
        )
      end

      it "only hits ESI once for repeated lookups" do
        2.times { record.corporation_name }
        expect(ESI).to have_received(:fetch_corporation_details).once
      end

      it "shares the cache entry across records for the same character" do
        record.corporation_name
        dummy_class.new(90_000_001).corporation_name
        expect(ESI).to have_received(:fetch_corporation_details).once
      end

      it "does not cache a failed lookup" do
        allow(ESI).to receive(:fetch_corporation_details)
          .and_return({ "name" => nil }, { "name" => "Test Corporation" })
        record.corporation_name
        expect(record.corporation_name).to eq("Test Corporation")
      end
    end
  end

  describe "#refresh_corporation_name" do
    before do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
      allow(ESI).to receive(:fetch_character_details).and_return({ "corporation_id" => 98_000_001 })
      allow(ESI).to receive(:fetch_corporation_details).and_return(
        { "name" => "Old Corporation" },
        { "name" => "New Corporation" }
      )
    end

    it "returns the freshly fetched name" do
      record.corporation_name
      expect(record.refresh_corporation_name).to eq("New Corporation")
    end

    it "leaves the new name cached" do
      record.corporation_name
      record.refresh_corporation_name
      expect(record.corporation_name).to eq("New Corporation")
    end
  end
end
