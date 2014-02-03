class AddMineralToYield < ActiveRecord::Migration
  def change
	add_column :yields, :mineral_id, :integer
  end
end
