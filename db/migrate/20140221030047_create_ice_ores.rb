class CreateIceOres < ActiveRecord::Migration
  def change
    create_table :ice_ores do |t|
      t.string :name
      t.float :volume
      t.integer :central_id
    end
  end
end
