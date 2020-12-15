class MarketOrdersController < ApplicationController
  def index
    @orders = current_user.orders
  end

  def update_all
    current_user.update_market_orders
    redirect_to market_orders_path
  end
end
