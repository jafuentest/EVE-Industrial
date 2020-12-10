class PlanetaryCommoditiesController < ApplicationController
  # GET /planetary_commodities
  # GET /planetary_commodities.json
  def index
    @planetary_commodities = PlanetaryCommodity.price_list(30_000_142)
  end

  # GET /planetary_commodities/1
  # GET /planetary_commodities/1.json
  def show
    @planetary_commodity = PlanetaryCommodity.with_price(params[:id], 30_000_142)
  end

  def my
    return redirect_to helpers.esi_login_url unless signed_in?

    @planets = PlanetaryCommodity.character_colonies(current_user)
  end

  # POST /planetary_commodities/update_prices
  def update_prices
    PlanetaryCommodity.update_prices

    redirect_to planetary_commodities_path
  end
end
