# == Schema Information
#
# Table name: planetary_commodities
#
#  id           :integer          not null, primary key
#  schematic_id :integer
#  name         :string           not null
#  tier         :integer          not null
#  volume       :decimal(5, 2)
#  batch_size   :integer          not null
#  input        :text
#
class PlanetaryCommodity < ApplicationRecord
  include CSVImportable
  include MarketeerAPI

  self.primary_key = :id

  has_many :items_prices, as: :item, class_name: 'ItemsPrices', dependent: :destroy

  def isk_per_hour(factories, buy_or_sell = :buy)
    price = buy_or_sell == :buy ? buy_price : sell_price
    daily_production = batch_size * factories * cycles_per_hour
    daily_production * price
  end

  def cycles_per_hour
    tier == 1 ? 2 : 1
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
    fields = 'buy_price / volume AS buy_isk_per_volume, sell_price / volume AS sell_isk_per_volume'
    all.select("id, name, tier, buy_price, sell_price, #{fields}")
      .joins('JOIN items_prices ON items_prices.item_id = planetary_commodities.id')
      .where("items_prices.star_id = #{system_id}")
      .order(name: 'asc')
  end

  def self.with_price(system_id:, **query_params)
    query = all.select('id, name, tier, volume, batch_size, buy_price, sell_price, input')
      .joins('JOIN items_prices ON items_prices.item_id = planetary_commodities.id')
      .where("items_prices.star_id = #{system_id}")

    return query if query_params.empty?

    query.find_by(query_params)
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
end
