class AddEveCentralIdToVariations < ActiveRecord::Migration
  def change
	add_column :variations, :central_id, :integer
  end
end
