class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.references :character, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.references :region, null: false, foreign_key: true
      t.bigint :esi_id
      t.bigint :location_id

      t.decimal :price, precision: 12, scale: 2
      t.boolean :buy_order
      t.integer :duration
      t.integer :volume_remain
      t.integer :volume_total
      t.datetime :issued

      t.timestamps
    end
  end
end
