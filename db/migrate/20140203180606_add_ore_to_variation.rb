class AddOreToVariation < ActiveRecord::Migration
  def change
	add_column :variations, :ore_id, :integer
  end
end
