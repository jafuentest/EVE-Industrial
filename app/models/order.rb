# == Schema Information
#
# Table name: orders
#
#  id            :integer          not null, primary key
#  item_id       :integer          not null
#  esi_id        :integer
#  location_id   :integer
#  user_id       :integer
#  price         :decimal(, )
#  issued        :datetime
#  duration      :integer
#  volume_remain :integer
#  volume_total  :integer
#  buy_order     :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Order < ApplicationRecord
  belongs_to :item
  belongs_to :user

  ESI_ATTRIBUTES = %w[location_id price issued duration volume_remain volume_total].freeze

  def placed_in_npc_station
    location_id < 100_000_000
  end

  def self.update_character_orders(user)
    orders = ESI.fetch_character_market_orders(user)
    Item.create_items(orders.pluck('type_id'))
    orders.each { |esi_order| upsert_order(esi_order, user) }
  end

  private_class_method def self.upsert_order(esi_order, user)
    o = find_or_initialize_by(esi_id: esi_order['order_id'])
    o.assign_attributes(esi_order.slice(*ESI_ATTRIBUTES))
    o.user = user
    o.item_id = esi_order['type_id']
    o.buy_order = esi_order['is_buy_order'].present?
    o.save!
  end
end
