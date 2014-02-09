class CreateSystems < ActiveRecord::Migration
  def change
    create_table :systems do |t|
      t.string :name
      t.integer :central_id
      t.integer :region_id
    end
  end
end
