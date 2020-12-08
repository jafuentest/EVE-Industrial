# == Schema Information
#
# Table name: planetary_commodities
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  tier       :integer          not null
#  volume     :decimal(5, 2)
#  batch_size :integer          not null
#  input      :text
#
class PlanetaryCommodity < ApplicationRecord
  include CSVImportable
  include MarketeerAPI

  PLANET_DETAILS_KEYS = %w(last_update planet_id planet_type solar_system_id upgrade_level)
  PIN_DETAILS_KEYS = %w(expiry_time extractor_details)
  HIGH_TECH_FACTORY_TYPE_IDS = [2475, 2482].freeze
  ADVANCED_FACTORY_TYPE_IDS = [2470, 2472, 2474, 2480, 2484, 2485, 2491, 2494].freeze
  BASIC_FACTORY_TYPE_IDS = [2469, 2471, 2473, 2481, 2483, 2490, 2492, 2493].freeze

  self.primary_key = :id

  has_many :items_prices, as: :item, class_name: 'ItemsPrices'

  def isk_per_hour(factories, buy_or_sell = :buy)
    batch_size * buy_price * factories * cycles_per_day
  end

  def cycles_per_day
    tier == 1 ? 48 : 24
  end

  def self.character_colonies(user)
    planet_list = ESI.fetch_character_planets(user)
    planets = ESI.fetch_planets_details(user, planet_list)
    planets.map do |planet|
      filtered_planet = planet.slice(*PLANET_DETAILS_KEYS)
        .merge('extractors' => nil, 'factories' => nil)

      filtered_planet['extractors'] = planet['pins'].reduce([]) do |pins, pin|
        pin.key?('extractor_details') ? pins << extractor_details(pin) : pins
      end

      filtered_planet.merge('factories' => self.fetch_top_level_factories(planet['pins']))
    end
  end

  def self.hash_from_csv_row(row)
    {
      id: row['ID'],
      name: row['Name'],
      tier: row['Tier'],
      volume: row['Volume'],
      batch_size: row['Batch Size']
    }
  end

  def self.update_prices
    Star.pluck(:id).each do |star_id|
      update_star_prices(star_id)
    end
  end

  def self.price_list(system_id)
    fields = 'id, name, tier, buy_price, sell_price, buy_price / volume AS buy_isk_per_volume, ' +
             'sell_price / volume AS sell_isk_per_volume'

    all.select(fields)
      .joins('JOIN items_prices ON items_prices.item_id = planetary_commodities.id')
      .where("items_prices.star_id = #{system_id}")
      .order(name: 'asc')
  end

  def self.with_price(id, system_id)
    all.select('name, buy_price, sell_price, batch_size, tier, volume')
      .joins('JOIN items_prices ON items_prices.item_id = planetary_commodities.id')
      .where("planetary_commodities.id = #{id} AND items_prices.star_id = #{system_id}")
      .first
  end

  def self.with_price_by(by, system_id)
    where(by).select('id, name, tier, buy_price, sell_price, batch_size, volume')
      .joins('JOIN items_prices ON items_prices.item_id = planetary_commodities.id')
      .where("items_prices.star_id = #{system_id}")
      .first
  end

  private_class_method def self.extractor_details(pin)
    details = pin['extractor_details'].slice('cycle_time', 'product_type_id', 'qty_per_cycle')
    {
      'expiry_time' => pin['expiry_time'],
      'extractor_details' => details
    }
  end

  private_class_method def self.update_star_prices(star_id)
    fetch_prices_for(star_id: star_id, items: pluck(:id)).each do |item|
      item_id = item['buy']['forQuery']['types'].first
      persist_price_data(star_id, item_id, item['buy']['max'], item['sell']['max'])
    end
  end

  private_class_method def self.persist_price_data(star_id, item_id, buy_price, sell_price)
    ItemsPrices.where(star_id: star_id, item_id: item_id).first_or_initialize.tap do |item_price|
      item_price.item_type = name
      item_price.buy_price = buy_price
      item_price.sell_price = sell_price
      item_price.save!
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
end
