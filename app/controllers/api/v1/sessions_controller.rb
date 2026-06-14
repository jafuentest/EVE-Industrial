class API::V1::SessionsController < ApplicationController
  include ESIHelper

  protect_from_forgery with: :null_session

  def show
    if user_signed_in?
      render json: { user: user_json(current_user) }
    else
      render json: { login_url: esi_login_url }, status: :unauthorized
    end
  end

  def destroy
    sign_out current_user if user_signed_in?
    render json: { ok: true }
  end

  private

  def user_json(user)
    {
      id: user.id,
      character_id: user.character_id,
      character_name: user.character_name,
      avatar: user.avatar
    }
  end
end
