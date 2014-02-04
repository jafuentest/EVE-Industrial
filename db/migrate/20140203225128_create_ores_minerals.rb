class CreateOresMinerals < ActiveRecord::Migration
  def change
    create_table :ores_minerals do |t|
      t.integer :ore_id
      t.integer :mineral_id
      t.float :share
    end
  end
end
