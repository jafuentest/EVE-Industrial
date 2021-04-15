module PlanetaryColoniesHelper
  def time_left(time)
    return 'expired' if Time.zone.now >= time

    "#{distance_of_time_in_words(Time.zone.now, time)} left"
  end

  def end_products(planet)
    products = planet.factories.pluck(:schematic_id).uniq.map do |schematic_id|
      schematic = PlanetaryCommodity.with_price(system_id: 30_000_142, schematic_id: schematic_id)
      tag.span schematic.id, data: { 'esi-id': schematic.id, 'esi-type': 'item' }
    end

    products.join(', ').html_safe
  end

  def row_class(planet)
    seconds_left = planet.expiry_time - Time.zone.now
    return '' if seconds_left > 1.day.to_i

    seconds_left.positive? ? 'bg-success' : 'bg-warning'
  end
end
