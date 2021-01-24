module PlanetaryCommoditiesHelper
  def time_left(pin)
    return 'expired' if Time.zone.now >= pin['expiry_time']

    "#{distance_of_time_in_words(Time.zone.now, pin['expiry_time'])} left"
  end
end
