class AddVariationToYields < ActiveRecord::Migration
  def change
	add_column :yields, :variation_id, :integer
  end
end
