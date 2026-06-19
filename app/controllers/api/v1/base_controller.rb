class API::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :require_authentication

  private

  def require_authentication
    render json: { error: "Unauthorized" }, status: :unauthorized unless user_signed_in?
  end
end
