class PlanetaryColony < ApplicationRecord
  belongs_to :character

  PLANET_DETAILS_KEYS = %w[last_update planet_id planet_type solar_system_id upgrade_level].freeze
  PIN_DETAILS_KEYS = %w[expiry_time extractor_details].freeze
  HIGH_TECH_FACTORY_TYPE_IDS = [2475, 2482].freeze
  ADVANCED_FACTORY_TYPE_IDS = [2470, 2472, 2474, 2480, 2484, 2485, 2491, 2494].freeze
  BASIC_FACTORY_TYPE_IDS = [2469, 2471, 2473, 2481, 2483, 2490, 2492, 2493].freeze

  def extractors
    JSON.parse(self[:extractors]).map &:with_indifferent_access
  end

  def extractors=(o)
    self[:extractors] = o.to_json
  end

  def factories
    JSON.parse(self[:factories]).map &:with_indifferent_access
  end

  def factories=(o)
    self[:factories] = o.to_json
  end

  def self.update_character_colonies(character)
    fetch_planets(character).each do |planet_data|
      colony = where(character_id: character.id, planet_id: planet_data['planet_id'])
        .first_or_initialize

      colony.assign_attributes(planet_data)
      colony.save!
    end
  end

  private_class_method def self.fetch_planets(character)
    ESI.fetch_planets_details(character).map do |planet|
      filtered_planet = planet.slice(*PLANET_DETAILS_KEYS)
        .merge('extractors' => nil, 'factories' => nil)

      filtered_planet['extractors'] = planet['pins'].reduce([]) do |pins, pin|
        pin.key?('extractor_details') ? pins << extractor_details(pin) : pins
      end

      filtered_planet.merge('factories' => fetch_top_level_factories(planet['pins']))
    end
  end

  private_class_method def self.fetch_top_level_factories(pins)
    top_level_factories = nil
    type_ids = [HIGH_TECH_FACTORY_TYPE_IDS, ADVANCED_FACTORY_TYPE_IDS, BASIC_FACTORY_TYPE_IDS]
    i = 0
    loop do
      top_level_factories = pins.filter { |e| type_ids[i].include? e['type_id'] }
      i += 1
      break if top_level_factories.present? || type_ids[i].blank?
    end

    top_level_factories
  end

  private_class_method def self.extractor_details(pin)
    details = pin['extractor_details'].slice('cycle_time', 'product_type_id', 'qty_per_cycle')
    {
      'expiry_time' => pin['expiry_time'],
      'extractor_details' => details
    }
  end
end
