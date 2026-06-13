# == Schema Information
#
# Table name: items_prices
#
#  star_id    :integer          not null
#  item_id    :integer          not null
#  item_type  :string           not null
#  buy_price  :decimal(12, 2)
#  sell_price :decimal(12, 2)
#  expires_at :datetime
#
class ItemsPrices < ApplicationRecord
  belongs_to :item, polymorphic: true
  belongs_to :star
end
