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
  belongs_to :user, optional: true

  ESI_ATTRIBUTES = %w[location_id price issued duration volume_remain volume_total].freeze

  def placed_in_npc_station
    location_id < 100_000_000
  end

  def market_diff
    matching = Order.where(item_id: item_id, location_id: location_id, buy_order: buy_order)

    market_best = buy_order ? matching.maximum(:price) : matching.minimum(:price)

    buy_order ? price - market_best : market_best - price
  end

  def self.update_citadel_orders(user, structure_id, item_ids = nil)
    page = 0
    loop do
      page += 1
      esi_orders = ESI.fetch_citadel_orders(user, structure_id, page)
      break if esi_orders.blank?

      esi_orders = esi_orders.select { |e| item_ids.include?(e['type_id']) } if item_ids.present?
      Item.create_items(esi_orders.pluck('type_id'))
      esi_orders.each { |esi_order| upsert_order(esi_order) }
    end
  end

  def self.update_character_orders(user)
    orders = ESI.fetch_character_market_orders(user)
    item_ids = orders.pluck('type_id')
    Item.create_items(item_ids)

    orders.each { |esi_order| upsert_order(esi_order, user) }

    orders.group_by { |e| e['location_id'] }.each do |location_id, location_orders|
      update_citadel_orders(user, location_id, location_orders.pluck('type_id'))
    end
  end

  private_class_method def self.upsert_order(esi_order, user = nil)
    o = find_or_initialize_by(esi_id: esi_order['order_id'])
    o.assign_attributes(esi_order.slice(*ESI_ATTRIBUTES))
    o.user = user if user.present?
    o.item_id = esi_order['type_id']
    o.buy_order = esi_order['is_buy_order'].present?
    o.save!
  end
end
