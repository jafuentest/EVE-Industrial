require 'csv'
require 'spec_helper'

RSpec.shared_examples_for 'csv_importable' do
  let(:model) { described_class }
  let(:model_factory) { model.to_s.underscore.to_sym }

  describe '#import_from_csv' do
    subject { model.import_from_csv('path_to_csv_file') }

    it 'calls delete_all' do
      allow(model).to receive(:delete_all).and_call_original
      subject
      expect(model).to have_received(:delete_all)
    end

    it 'removes existing records' do
      existing = FactoryBot.create(model_factory)
      subject
      expect { existing.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'calls insert_all!' do
      allow(model).to receive(:insert_all!).and_call_original
      subject
      expect(model).to have_received(:insert_all!)
    end

    it 'returns an ActiveRecord::Result' do
      expect(subject).to be_a(ActiveRecord::Result)
    end

    context 'when called with invalid data' do
      before { allow(CSV).to receive(:read).and_return([{ 'invalid' => 'data' }]) }

      skip 'rolls back deletion' do
        # TODO
      end

      it 'calls delete_all before raising' do
        allow(model).to receive(:delete_all).and_call_original
        subject
        expect(model).to have_received(:delete_all)
      end

      it 'attempts insert_all! before raising' do
        allow(model).to receive(:insert_all!).and_call_original
        subject
        expect(model).to have_received(:insert_all!)
      end

      it 'returns a string with the error' do
        expect(subject).to include('ActiveRecord::NotNullViolation')
      end
    end
  end
end
