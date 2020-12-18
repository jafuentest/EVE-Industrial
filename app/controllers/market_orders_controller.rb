class MarketOrdersController < ApplicationController
  def index
    return redirect_to helpers.esi_login_url unless signed_in?

    @orders = current_user.orders.joins(:item)
  end

  def update_all
    return redirect_to helpers.esi_login_url unless signed_in?

    current_user.update_market_orders
    redirect_to market_orders_path
  end
end
