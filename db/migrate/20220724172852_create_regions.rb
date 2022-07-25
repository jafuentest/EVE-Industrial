class CreateRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :regions, id: false do |t|
      t.bigint :id, null: false
      t.string :name, null: false

      t.index :id, unique: true
    end
  end
end
