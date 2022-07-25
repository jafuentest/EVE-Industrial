# == Schema Information
#
# Table name: industry_jobs
#
#  id                :integer          not null, primary key
#  character_id      :integer
#  blueprint_id      :integer
#  blueprint_type_id :integer
#  product_type_id   :integer
#  activity_id       :integer
#  station_id        :integer
#  installer_id      :integer
#  start_date        :datetime
#  end_date          :datetime
#  runs              :integer
#  licensed_runs     :integer
#  probability       :decimal(5, 4)
#  status            :string
#
class IndustryJob < ApplicationRecord
  ESI_ATTRIBUTES = %w[
    character_id blueprint_id blueprint_type_id product_type_id activity_id station_id installer_id
    start_date end_date runs licensed_runs probability status
  ].freeze

  JOB_ACTIVITY_ID = [
    '',
    'Manufacturing',
    'Researching Technology',
    'TE Research',
    'ME Research',
    'Copying',
    'Duplicating',
    'Reverse Engineering',
    'Invention'
  ].freeze

  self.primary_key = :id

  belongs_to :character
  belongs_to :output, foreign_key: :product_type_id, class_name: 'Item', inverse_of: :industry_jobs

  def self.update_character_jobs(character)
    esi_jobs = ESI.fetch_character_industry_jobs(character)
    Item.create_items(esi_jobs.pluck('product_type_id'))
    remove_missing_jobs(character, esi_jobs)
    esi_jobs.each do |esi_job|
      job = find_or_initialize_by(id: esi_job['job_id'])
      next if job.persisted?

      job.assign_attributes(esi_job.slice(*ESI_ATTRIBUTES))
      job.character = character
      job.save!
    end
  end

  private_class_method def self.remove_missing_jobs(character, esi_jobs)
    character.industry_jobs.where.not(id: esi_jobs.pluck('job_id')).delete_all
  end

  def activity
    JOB_ACTIVITY_ID[activity_id]
  end

  def time_left
    return 0 if end_date < Time.current

    end_date - Time.current
  end

  def status
    end_date < Time.current ? 'ready' : self[:status]
  end

  def probability
    return '' unless activity == 'Invention'

    "#{(self[:probability] * 100).round(2)}%"
  end

  def completion_percent
    total_time = end_date - start_date
    percent = (total_time - time_left) * 100 / total_time
    "#{percent}%"
  end
end
