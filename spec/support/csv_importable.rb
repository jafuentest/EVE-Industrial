require 'csv'
require 'spec_helper'

RSpec.shared_examples_for 'csv_importable' do
  let(:model) { described_class }
  let(:model_factory) { model.to_s.underscore.to_sym }

  describe '#import_from_csv' do
    subject { model.import_from_csv('path_to_csv_file') }

    it "clears model's table" do
      existing = FactoryBot.create(model_factory)
      allow(model).to receive(:delete_all).and_call_original
      subject
      expect(model).to have_received(:delete_all)
      expect { existing.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'rebuilds database table from CSV' do
      allow(model).to receive(:insert_all!).and_call_original
      expect(subject).to be_a(ActiveRecord::Result)
      expect(model).to have_received(:insert_all!)
    end

    context 'when called with invalid data' do
      skip 'rolls back deletion' do
        # TODO
      end

      it 'return string with error' do
        allow(CSV).to receive(:read).and_return([{ 'invalid' => 'data' }])

        allow(model).to receive(:delete_all).and_call_original
        allow(model).to receive(:insert_all!).and_call_original

        result = model.import_from_csv('path_to_csv_file')
        expect(model).to have_received(:delete_all)
        expect(model).to have_received(:insert_all!)
        expect(result).to include('ActiveRecord::NotNullViolation')
      end
    end
  end
end
