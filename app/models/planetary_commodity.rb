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

  self.primary_key = :id

  has_many :items_prices, as: :item, class_name: 'ItemsPrices'

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
