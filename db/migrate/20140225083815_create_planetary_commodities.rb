class CreatePlanetaryCommodities < ActiveRecord::Migration
  def change
    create_table :planetary_commodities do |t|
      t.string :name
      t.float :volume
      t.integer :quantity
      t.integer :tier
      t.integer :central_id
    end
  end
end
