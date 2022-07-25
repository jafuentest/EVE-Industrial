class CreateConstellations < ActiveRecord::Migration[7.0]
  def change
    create_table :constellations, id: false do |t|
      t.bigint :id, null: false
      t.references :region, null: false, foreign_key: true
      t.string :name, null: false

      t.index :id, unique: true
    end
  end
end
