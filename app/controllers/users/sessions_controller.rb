class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  skip_before_action :require_no_authentication, only: [:new]

  # GET /login
  def new
    return redirect_to root_path if (code = params[:code]).blank?

    do_sign_in(code) unless signed_in?

    add_character(code) if params[:state].include?('character')

    redirect_to settings_path
  end

  # POST /users/sign_in
  # def create
  #   super
  # end

  # DELETE /users/sign_out
  # def destroy
  #   super
  # end

  private

  def do_sign_in(code)
    self.resource = User.find_or_register(code)
    sign_in(resource_name, resource)
  end

  def add_character(code)
    User.add_character(code, current_user.id) if params[:state].include?('character')
  end
end
