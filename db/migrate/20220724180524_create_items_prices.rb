class CreateItemsPrices < ActiveRecord::Migration[6.0]
  def change
    create_table :items_prices, id: false do |t|
      t.references :star, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.string :item_type, null: false

      t.decimal :buy_price, precision: 12, scale: 2
      t.decimal :sell_price, precision: 12, scale: 2

      t.index %i[item_id star_id]
    end
  end
end
