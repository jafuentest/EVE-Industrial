class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :esi_id
      t.integer :location_id
      t.integer :region_id
      t.integer :character_id
      t.decimal :price, precision: 12, scale: 2
      t.datetime :issued
      t.integer :duration
      t.integer :volume_remain
      t.integer :volume_total
      t.boolean :buy_order

      t.timestamps
    end
  end
end
