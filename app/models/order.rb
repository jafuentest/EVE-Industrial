class Order < ApplicationRecord
  belongs_to :item

  def placed_in_npc_station
    location_id < 100_000_000
  end

  def self.update_character_orders(user)
    orders = ESI.fetch_character_market_orders(user)
    create_items(orders.pluck('type_id'))
    orders.each do |esi_order|
      update_order(esi_order)
    end
  end

  private_class_method def self.update_order(esi_order)
    order = find_or_initialize_by(esi_id: esi_order['order_id']).tap do |o|
      o.item_id = esi_order['type_id']
      o.location_id = esi_order['location_id']
      o.price = esi_order['price']
      o.issued = DateTime.parse(esi_order['issued'])
      o.duration = esi_order['duration']
      o.save!
    end
  end

  private_class_method def self.create_items(item_ids)
    item_ids.each do |item_id|
      Item.find_or_create_by!(id: item_id)
    end
  end
end
