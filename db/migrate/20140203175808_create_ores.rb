class CreateOres < ActiveRecord::Migration
  def change
    create_table :ores do |t|
      t.string :name
      t.integer :refine
      t.float :volume
    end
  end
end
