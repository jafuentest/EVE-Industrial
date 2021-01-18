class IndustryJob < ApplicationRecord
  ESI_ATTRIBUTES = %w[
    character_id blueprint_id blueprint_type_id product_type_id activity_id station_id installer_id
    start_date end_date runs licensed_runs probability status
  ].freeze

  JOB_ACTIVITY_ID = [
    '',
    'Manufacturing',
    'Researching Technology',
    'Researching TE',
    'Researching ME',
    'Copying',
    'Duplicating',
    'Reverse Engineering',
    'Invention'
  ].freeze

  self.primary_key = :id

  belongs_to :character
  belongs_to :output, foreign_key: :product_type_id, class_name: 'Item'

  def self.update_character_industry_jobs(character)
    esi_jobs = ESI.fetch_character_industry_jobs(character).each
    Item.create_items(esi_jobs.pluck('product_type_id'))

    esi_jobs.each do |esi_job|
      job = find_or_initialize_by(id: esi_job['job_id'])
      next if job.persisted?

      job.assign_attributes(esi_job.slice(*ESI_ATTRIBUTES))
      job.character = character
      job.save!
    end
  end

  def activity
    JOB_ACTIVITY_ID[activity_id]
  end
end
