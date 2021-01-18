class IndustryController < ApplicationController
  def jobs
    return redirect_to helpers.esi_login_url unless signed_in?

    @jobs = current_user.industry_jobs.joins(:output)
  end
end
