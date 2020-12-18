class UsersController < ApplicationController
  def settings; end

  def remove_character
    Character.find(params[:id]).destroy
    redirect_to settings_path
  end
end
