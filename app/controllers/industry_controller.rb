class IndustryController < ApplicationController
  def jobs
    return redirect_to helpers.esi_login_url unless signed_in?

    @jobs = current_user.industry_jobs
      .joins(:output)
      .order(:end_date)
  end

  def update_jobs
    return redirect_to helpers.esi_login_url unless signed_in?

    current_user.update_industry_jobs
    redirect_to industry_jobs_path
  end
end
