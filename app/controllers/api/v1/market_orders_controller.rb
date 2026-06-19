class API::V1::MarketOrdersController < API::V1::BaseController
  def index
    orders = current_user.orders.joins(:item)
    grouped = orders.group_by(&:character).map do |character, char_orders|
      char_orders.reject! { |o| o.market_diff.zero? } if params[:filter] == "relevant"
      {
        character: character_json(character),
        orders: char_orders.map { |o| order_json(o) }
      }
    end
    render json: grouped
  end

  private

  def character_json(character)
    {
      id: character.id,
      character_name: character.character_name
    }
  end

  def order_json(order)
    {
      id: order.id,
      item_id: order.item_id,
      item_name: order.item.name,
      volume_remain: order.volume_remain,
      volume_total: order.volume_total,
      price: order.price,
      market_diff: order.market_diff,
      location_id: order.location_id,
      issued: order.issued,
      buy_order: order.buy_order
    }
  end
end
