require 'rails_helper'

RSpec.describe IndustryJob, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:industry_job)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:character) }
    it { is_expected.to belong_to(:output).class_name('Item') }
  end

  describe '.update_character_jobs' do
    subject(:update_jobs) { described_class.update_character_jobs(character) }

    let(:character) { FactoryBot.create(:character) }
    let(:item) { FactoryBot.create(:item) }
    let(:esi_job) do
      {
        'job_id' => 1,
        'character_id' => character.character_id,
        'blueprint_id' => 1_000_001,
        'blueprint_type_id' => 2_000_001,
        'product_type_id' => item.id,
        'activity_id' => 1,
        'station_id' => 3_000_001,
        'installer_id' => character.character_id,
        'start_date' => 1.hour.ago.iso8601,
        'end_date' => 1.hour.from_now.iso8601,
        'runs' => 1,
        'licensed_runs' => 1,
        'probability' => nil,
        'status' => 'active'
      }
    end

    before do
      allow(ESI).to receive(:fetch_character_industry_jobs).and_return([esi_job])
      allow(Item).to receive(:create_items)
    end

    it 'fetches jobs from ESI' do
      update_jobs
      expect(ESI).to have_received(:fetch_character_industry_jobs).with(character)
    end

    it 'creates missing items for products' do
      update_jobs
      expect(Item).to have_received(:create_items).with([item.id])
    end

    it 'creates a new job from ESI data' do
      expect { update_jobs }.to change(described_class, :count).by(1)
    end

    it 'does not duplicate an existing job' do
      FactoryBot.create(:industry_job, id: 1, character:, output: item)
      expect { update_jobs }.not_to change(described_class, :count)
    end

    it 'removes jobs no longer returned by ESI' do
      stale_job = FactoryBot.create(:industry_job, character:, output: item)
      update_jobs
      expect(described_class.exists?(stale_job.id)).to be false
    end

    it 'does not remove jobs belonging to other characters' do
      other_job = FactoryBot.create(:industry_job, output: item)
      update_jobs
      expect(described_class.exists?(other_job.id)).to be true
    end
  end

  describe '#activity' do
    it 'returns the activity name for the given activity_id' do
      job = FactoryBot.build(:industry_job, activity_id: 1)
      expect(job.activity).to eq('Manufacturing')
    end

    it 'returns Invention for activity_id 8' do
      job = FactoryBot.build(:industry_job, :invention)
      expect(job.activity).to eq('Invention')
    end
  end

  describe '#time_left' do
    context 'when job is finished' do
      let(:job) { FactoryBot.build(:industry_job, :completed) }

      it 'returns 0' do
        expect(job.time_left).to eq(0)
      end
    end

    context 'when job is still running' do
      let(:job) { FactoryBot.build(:industry_job, end_date: 1.hour.from_now) }

      it 'returns seconds remaining' do
        expect(job.time_left).to be_within(5).of(1.hour)
      end
    end
  end

  describe '#status' do
    context 'when job is finished' do
      let(:job) { FactoryBot.build(:industry_job, :completed, status: 'active') }

      it 'returns ready' do
        expect(job.status).to eq('ready')
      end
    end

    context 'when job is still running' do
      let(:job) { FactoryBot.build(:industry_job, status: 'active') }

      it 'returns the stored status' do
        expect(job.status).to eq('active')
      end
    end
  end

  describe '#probability' do
    context 'when job is not Invention' do
      let(:job) { FactoryBot.build(:industry_job, activity_id: 1) }

      it 'returns an empty string' do
        expect(job.probability).to eq('')
      end
    end

    context 'when job is Invention' do
      let(:probability) { 0.3562 }
      let(:job) { FactoryBot.build(:industry_job, :invention, probability:) }

      it 'returns the probability as a percentage string' do
        expect(job.probability).to eq('35.62%')
      end
    end
  end

  describe '#completion_percent' do
    context 'when job is finished' do
      let(:job) { FactoryBot.build(:industry_job, :completed) }

      it 'returns 100%' do
        expect(job.completion_percent).to eq('100.0%')
      end
    end

    context 'when job is halfway done' do
      let(:job) do
        FactoryBot.build(:industry_job, start_date: 1.hour.ago, end_date: 1.hour.from_now)
      end

      it 'returns approximately 50%' do
        percent = job.completion_percent.to_f
        expect(percent).to be_within(1).of(50.0)
      end
    end
  end
end
