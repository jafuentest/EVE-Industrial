class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items, id: false do |t|
      t.bigint :id, null: false
      t.string :name

      t.index :id, unique: true
    end
  end
end
