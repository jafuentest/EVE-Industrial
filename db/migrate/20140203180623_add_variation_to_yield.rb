class AddVariationToYield < ActiveRecord::Migration
  def change
	add_column :yields, :variation_id, :integer
  end
end
