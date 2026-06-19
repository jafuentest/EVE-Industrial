class API::V1::PlanetaryCommoditiesController < API::V1::BaseController
  SYSTEM_ID = 30_000_142

  def index
    commodities = PlanetaryCommodity.price_list(SYSTEM_ID)
    render json: commodities.map { |c| index_json(c) }
  end

  def show
    commodity = PlanetaryCommodity.with_price(system_id: SYSTEM_ID, id: params[:id])
    return render json: { error: "Not found" }, status: :not_found if commodity.nil?

    render json: show_json(commodity)
  end

  def update
    PlanetaryCommodity.update_prices
    head :ok
  end

  private

  def index_json(commodity)
    {
      id: commodity.id,
      name: commodity.name,
      tier: commodity.tier,
      buy_price: commodity[:buy_price],
      sell_price: commodity[:sell_price],
      buy_isk_per_volume: commodity[:buy_isk_per_volume],
      sell_isk_per_volume: commodity[:sell_isk_per_volume]
    }
  end

  def show_json(commodity)
    {
      id: commodity.id,
      name: commodity.name,
      tier: commodity.tier,
      volume: commodity.volume,
      batch_size: commodity.batch_size,
      buy_price: commodity[:buy_price],
      sell_price: commodity[:sell_price],
      input: commodity.input
    }
  end
end
