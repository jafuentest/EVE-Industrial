class RemoveBonusFromYields < ActiveRecord::Migration
  def change
	remove_column :yields, :bonus
  end
end
