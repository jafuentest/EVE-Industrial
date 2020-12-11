class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :esi_id
      t.integer :location_id
      t.decimal :price
      t.datetime :issued
      t.integer :duration

      t.timestamps
    end
  end
end
