module MarketOrdersHelper
  def row_class(order)
    order.buy_order ? 'bg-info' : 'bg-success'
  end
end
