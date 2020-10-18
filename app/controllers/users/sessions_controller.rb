class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /login
  def new
    return redirect_to character_data_path if signed_in?
    return redirect_to root_path if params[:code].blank?

    self.resource = User.find_or_register(params[:code])
    sign_in(resource_name, resource)

    redirect_to character_data_path
  end

  # POST /users/sign_in
  # def create
  #   super
  # end

  # DELETE /users/sign_out
  # def destroy
  #   super
  # end
end
