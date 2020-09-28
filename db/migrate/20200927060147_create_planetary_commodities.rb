class CreatePlanetaryCommodities < ActiveRecord::Migration[6.0]
  def change
    create_table :planetary_commodities, id: false do |t|
      t.integer :id, null: false
      t.string :name
      t.integer :tier
      t.decimal :volume, precision: 5, scale: 2
      t.integer :batch_size
      t.text :input

      t.index :id, unique: true
    end
  end
end
