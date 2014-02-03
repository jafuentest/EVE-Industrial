class CreateMinerals < ActiveRecord::Migration
  def change
    create_table :minerals do |t|
      t.string :name
      t.string :volume
    end
  end
end
