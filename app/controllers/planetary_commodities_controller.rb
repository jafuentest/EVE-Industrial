class PlanetaryCommoditiesController < ApplicationController
  # GET /planetary_commodities
  # GET /planetary_commodities.json
  def index
    @planetary_commodities = PlanetaryCommodity.all
      .select('id, name, tier, volume, buy_price, sell_price, input')
      .joins('JOIN items_prices ON items_prices.item_id = planetary_commodities.id')
      .where('items_prices.star_id = 30000142')
      .order(buy_price: 'desc')
  end

  # GET /planetary_commodities/1
  # GET /planetary_commodities/1.json
  def show
    @planetary_commodity = PlanetaryCommodity.all
      .select('name, buy_price, sell_price, batch_size, tier, volume, input')
      .joins('JOIN items_prices ON items_prices.item_id = planetary_commodities.id')
      .where('items_prices.star_id = 30000142')
      .where(id: params[:id]).first
  end

  # POST /planetary_commodities/update_prices
  def update_prices
    PlanetaryCommodity.update_prices

    redirect_to planetary_commodities_path
  end
end
