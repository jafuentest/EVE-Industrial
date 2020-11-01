class PlanetaryCommoditiesController < ApplicationController
  # GET /planetary_commodities
  # GET /planetary_commodities.json
  def index
    @planetary_commodities = PlanetaryCommodity.price_list(30000142)
  end

  # GET /planetary_commodities/1
  # GET /planetary_commodities/1.json
  def show
    @planetary_commodity = PlanetaryCommodity.with_price(params[:id], 30000142)
  end

  # POST /planetary_commodities/update_prices
  def update_prices
    PlanetaryCommodity.update_prices

    redirect_to planetary_commodities_path
  end
end
