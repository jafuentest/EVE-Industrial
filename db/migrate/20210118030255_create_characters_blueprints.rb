class CreateCharactersBlueprints < ActiveRecord::Migration[6.0]
  def change
    create_table :characters_blueprints do |t|
      t.integer :character_id
      t.integer :type_id
      t.integer :location_id
      t.string :location_flag
      t.integer :quantity
      t.integer :material_efficiency
      t.integer :time_efficiency
      t.integer :runs

      t.timestamps
    end
  end
end
