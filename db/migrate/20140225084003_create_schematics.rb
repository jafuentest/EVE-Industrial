class CreateSchematics < ActiveRecord::Migration
  def change
    create_table :schematics do |t|
      t.integer :output_id
      t.integer :input_id
      t.integer :quantity
    end
  end
end
