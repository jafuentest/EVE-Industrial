# == Schema Information
#
# Table name: orders
#
#  id            :integer          not null, primary key
#  item_id       :integer          not null
#  esi_id        :integer
#  location_id   :integer
#  region_id     :integer
#  character_id  :integer
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
  belongs_to :character, optional: true

  alias_attribute :type_id, :item_id

  ESI_ATTRIBUTES = %w[location_id type_id price issued duration volume_remain volume_total].freeze
  NPC_ID_THRESHOLD = 100_000_000
  SYSTEMS_FOR_REGION = {
    # The Forge => [Jita, Perimeter, New Caldari]
    10_000_002 => [30_000_142, 30_000_144, 30_000_145]
  }.freeze

  def market_diff
    return market_diff_citadel unless placed_in_npc_station?

    matching = Order.where(item_id: item_id, region_id: region_id, buy_order: buy_order)

    market_best = buy_order ? matching.maximum(:price) : matching.minimum(:price)

    buy_order ? price - market_best : market_best - price
  end

  def market_diff_citadel
    matching = Order.where(item_id: item_id, location_id: location_id, buy_order: buy_order)

    market_best = buy_order ? matching.maximum(:price) : matching.minimum(:price)

    buy_order ? price - market_best : market_best - price
  end

  def self.npc_station?(location_id)
    location_id < NPC_ID_THRESHOLD
  end

  def self.update_character_orders(character, update_competition: true)
    start_time = Time.current
    orders = ESI.fetch_character_market_orders(character)
    Item.create_items(orders.pluck('type_id'))
    orders.each do |esi_order|
      upsert_order(esi_order, character: character, region_id: esi_order['region_id'])
    end

    if update_competition
      update_competing_orders(orders, character)
      destroy_missing_orders(orders, start_time)
    end
  end

  def self.update_competing_orders(orders, character)
    orders.group_by { |e| e['location_id'] }.each do |location_id, location_orders|
      if npc_station?(location_id)
        update_region_orders(location_orders.first['region_id'], location_orders.pluck('type_id'))
      else
        update_citadel_orders(character, location_id, location_orders.pluck('type_id'))
      end
    end
  end

  private_class_method def self.destroy_missing_orders(orders, time)
    orders.group_by { |e| e['location_id'] }.each do |location_id, location_orders|
      orders = Order.where('updated_at < ?', time)
      orders =
        if npc_station?(location_id)
          orders.where(region_id: location_orders.first['region_id'])
        else
          orders.where(location_id: location_id)
        end
      orders.delete_all
    end
  end

  private_class_method def self.update_region_orders(region_id, item_ids)
    Item.create_items(item_ids)
    item_ids.each do |item_id|
      ESI.fetch_region_orders(region_id, item_id, 'all')
        .select { |e| SYSTEMS_FOR_REGION[region_id].include?(e['system_id']) }
        .each { |esi_order| upsert_order(esi_order, region_id: region_id) }
    end
  end

  private_class_method def self.update_citadel_orders(character, structure_id, item_ids = nil)
    page = 0
    loop do
      page += 1
      esi_orders = ESI.fetch_citadel_orders(character, structure_id, page)
      break if esi_orders.blank?

      esi_orders = esi_orders.select { |e| item_ids.include?(e['type_id']) } if item_ids.present?
      Item.create_items(esi_orders.pluck('type_id'))
      esi_orders.each { |esi_order| upsert_order(esi_order) }
    end
  end

  private_class_method def self.upsert_order(esi_order, character: nil, region_id: nil)
    o = find_or_initialize_by(esi_id: esi_order['order_id'])
    o.assign_attributes(esi_order.slice(*ESI_ATTRIBUTES))
    o.region_id = region_id
    o.buy_order = esi_order['is_buy_order'].present?
    o.character = character if character.present?
    o.updated_at = Time.current if o.persisted?
    o.save!
  end

  private

  def placed_in_npc_station?
    self.class.npc_station?(location_id)
  end
end
