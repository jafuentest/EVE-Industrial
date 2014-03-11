class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :is_admin
  
  def is_admin
    if session[:user_id].nil? || ! session[:is_admin]
      flash[:notice] = 'The action you tried to perform is restricted'
      redirect_to :back
    end
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end
end
