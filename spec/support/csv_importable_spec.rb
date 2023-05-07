require 'csv'
require 'spec_helper'

RSpec.shared_examples_for 'csv_importable' do |params|
  let(:model) { described_class }
  let(:model_factory) { model.to_s.underscore.to_sym }

  describe '#import_from_csv' do
    it 'rebuilds database table from CSV' do
      existing = FactoryBot.create(model_factory)

      expect(model).to receive(:delete_all).and_call_original
      expect(model).to receive(:insert_all!).and_call_original

      result = model.import_from_csv('path_to_csv_file')
      expect(result).to be_kind_of(ActiveRecord::Result)
      expect { existing.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'when called with invalid data' do
      it 'return string with error' do
        allow(CSV).to receive(:read).and_return([{ 'invalid' => 'data' }])

        expect(model).to receive(:delete_all).and_call_original
        expect(model).to receive(:insert_all!).and_call_original

        result = model.import_from_csv('path_to_csv_file')
        expect(result).to include('ActiveRecord::NotNullViolation')
      end
    end
  end
end
