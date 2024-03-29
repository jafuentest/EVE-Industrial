class CreatePlanetaryCommodities < ActiveRecord::Migration[6.0]
  def change
    create_table :planetary_commodities, id: false do |t|
      t.bigint :id, null: false
      t.bigint :schematic_id
      t.string :name, null: false
      t.integer :tier, null: false
      t.decimal :volume, precision: 5, scale: 2
      t.integer :batch_size, null: false
      t.text :input

      t.index :id, unique: true
    end
  end
end
