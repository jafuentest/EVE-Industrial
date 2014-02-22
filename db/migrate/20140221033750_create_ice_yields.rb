class CreateIceYields < ActiveRecord::Migration
  def change
    create_table :ice_yields do |t|
      t.integer :quantity
      t.integer :ice_ore_id
      t.integer :ice_product_id
    end
  end
end
