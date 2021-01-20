namespace :orders do
  desc 'Calls update_character_orders method for every character'
  task import: :environment do
    start_time = Time.current
    Character.all.each do |character|
      Order.update_character_orders(character, update_competition: false)
    end

    Order.group(:location_id).pluck(:location_id).each do |location_id|
      location_orders = Order.where(location_id: location_id)
      Order.update_competing_orders(location_orders, location_orders.first.character)

      missing_orders = Order.where('updated_at < ?', start_time)
      missing_orders =
        if Order.npc_station?(location_id)
          missing_orders.where(region_id: Order.where(location_id: location_id).first.region_id)
        else
          missing_orders.where(location_id: location_id)
        end
      missing_orders.delete_all
    end
  end
end
