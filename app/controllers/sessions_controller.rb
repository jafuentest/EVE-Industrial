class SessionsController < ApplicationController
  skip_before_filter :is_admin
  
  def new
  end

  def create
    user = User.authenticate(params[:session])
    if (user)
      session[:user_id] = user.id
      session[:is_admin] = user.is_admin
      user.last_login = DateTime.now
      user.save
      redirect_to root_path, { :notice => 'Login success, welcome back!' }
    else
      redirect_to login_path, { :notice => 'Login failure' }
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
