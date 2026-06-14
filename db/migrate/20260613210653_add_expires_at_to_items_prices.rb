class AddExpiresAtToItemsPrices < ActiveRecord::Migration[8.1]
  def change
    add_column :items_prices, :expires_at, :datetime
  end
end
