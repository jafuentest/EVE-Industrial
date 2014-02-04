class AddEveCentralIdToMinerals < ActiveRecord::Migration
  def change
	add_column :minerals, :central_id, :integer
  end
end
