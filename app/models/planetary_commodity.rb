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
  include EveTycoonAPI

  self.primary_key = :id

  has_many :items_prices, as: :item, class_name: "ItemsPrices", dependent: :destroy

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
      id: row["ID"],
      name: row["Name"],
      tier: row["Tier"],
      volume: row["Volume"],
      batch_size: row["Batch Size"]
    }
  end

  def self.update_prices
    update_star_prices(Star::IDs::JITA)
  end

  def self.price_list(system_id)
    fields = "buy_price / volume AS buy_isk_per_volume, sell_price / volume AS sell_isk_per_volume"
    select("id, name, tier, buy_price, sell_price, #{fields}")
      .joins("JOIN items_prices ON items_prices.item_id = planetary_commodities.id")
      .where("items_prices.star_id = #{system_id}")
      .order(name: "asc")
  end

  def self.with_price(system_id:, **query_params)
    query = select("id, name, tier, volume, batch_size, buy_price, sell_price, input")
      .joins("JOIN items_prices ON items_prices.item_id = planetary_commodities.id")
      .where("items_prices.star_id = #{system_id}")

    return query if query_params.empty?

    query.find_by(query_params)
  end

  private_class_method def self.update_star_prices(star_id)
    region_id = Star.find(star_id).region_id
    fetch_prices_for(region_id:, items: stale_item_ids(star_id)).each do |price_result|
      item_id = price_result["item_id"]
      persist_price_data(star_id, item_id, price_result["buyAvgFivePercent"], price_result["sellAvgFivePercent"], price_result["expires_at"])
    end
  end

  private_class_method def self.stale_item_ids(star_id)
    all_ids = pluck(:id)
    fresh_ids = ItemsPrices.where(star_id:, item_id: all_ids)
      .where("expires_at > ?", Time.current)
      .pluck(:item_id)
    all_ids - fresh_ids
  end

  private_class_method def self.persist_price_data(star_id, item_id, buy_price, sell_price, expires_at = nil)
    ItemsPrices.where(star_id:, item_id:).first_or_initialize.tap do |item_price|
      item_price.item_type = name
      item_price.buy_price = buy_price
      item_price.sell_price = sell_price
      item_price.expires_at = expires_at
      item_price.save!
    end
  end
end
