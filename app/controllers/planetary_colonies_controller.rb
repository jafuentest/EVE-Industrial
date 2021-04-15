class PlanetaryColoniesController < ApplicationController
  def index
    return redirect_to helpers.esi_login_url unless signed_in?

    @planets = Character.first.planetary_colonies
  end

  def update
    @planets = current_user.update_planetary_colonies
    redirect_to planetary_colonies_path
  end
end
