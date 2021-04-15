class PlanetaryCommoditiesController < ApplicationController
  # GET /planetary_commodities
  # GET /planetary_commodities.json
  def index
    @planetary_commodities = PlanetaryCommodity.price_list(30_000_142)
  end

  # GET /planetary_commodities/1
  # GET /planetary_commodities/1.json
  def show
    @planetary_commodity = PlanetaryCommodity.with_price(system_id: 30_000_142, id: params[:id])
  end

  def update_colonies
    @planets = current_user.update_planetary_colonies
    redirect_to my_planets_path
  end

  def my
    return redirect_to helpers.esi_login_url unless signed_in?

    @planets = Character.first.planetary_colonies
  end

  # POST /planetary_commodities/update_prices
  def update_prices
    PlanetaryCommodity.update_prices

    redirect_to planetary_commodities_path
  end
end
