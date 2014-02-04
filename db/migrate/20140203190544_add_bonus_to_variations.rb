class AddBonusToVariations < ActiveRecord::Migration
  def change
	add_column :variations, :bonus, :integer
  end
end
