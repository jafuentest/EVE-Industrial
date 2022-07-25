class CreateStars < ActiveRecord::Migration[6.0]
  def change
    create_table :stars, id: false do |t|
      t.bigint :id, null: false
      t.string :name, null: false
      t.references :constellation, null: false, foreign_key: true
      t.references :region, null: false, foreign_key: true

      t.index :id, unique: true
    end
  end
end
