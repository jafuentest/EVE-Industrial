class API::V1::IndustryJobsController < API::V1::BaseController
  def index
    jobs = current_user.industry_jobs.joins(:output).order(:end_date)
    grouped = jobs.group_by(&:character).map do |character, char_jobs|
      {
        character: { id: character.id, character_name: character.character_name },
        jobs: char_jobs.map { |job| job_json(job) }
      }
    end
    render json: grouped
  end

  def update
    current_user.update_industry_jobs
    head :ok
  end

  private

  def job_json(job)
    {
      id: job.id,
      runs: job.runs,
      activity: job.activity,
      probability: job.probability,
      output_name: job.output.name,
      station_id: job.station_id,
      start_date: job.start_date,
      end_date: job.end_date,
      status: job.status,
      time_left: job.time_left,
      completion_percent: job.completion_percent
    }
  end
end
