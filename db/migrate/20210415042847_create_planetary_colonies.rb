class CreatePlanetaryColonies < ActiveRecord::Migration[6.0]
  def change
    create_table :planetary_colonies do |t|
      t.references :character, null: false, foreign_key: true
      t.integer :solar_system_id, null: false
      t.integer :planet_id, null: false
      t.string :planet_type, null: false
      t.integer :upgrade_level, null: false
      t.datetime :last_update
      t.string :extractors, default: '{}'
      t.string :factories, default: '{}'
      t.timestamps
    end
  end
end
