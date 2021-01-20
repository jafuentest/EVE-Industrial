module IndustryHelper
  def row_class(job)
    color = job.activity_id == 1 ? 'bg-success' : 'bg-info'
    job.time_left <= 0 ? "#{color} fw-bold" : color
  end
end
