class CreateStars < ActiveRecord::Migration[6.0]
  def change
    create_table :stars, id: false do |t|
      t.integer :id, null: false
      t.string :name, null: false
      t.integer :constellation_id, null: false
      t.integer :region_id, null: false

      t.index :id, unique: true
    end
  end
end
