class MakeItemsPricesIndexUnique < ActiveRecord::Migration[8.1]
  def change
    remove_index :items_prices, %i[item_id star_id]
    add_index :items_prices, %i[item_id star_id], unique: true
  end
end
