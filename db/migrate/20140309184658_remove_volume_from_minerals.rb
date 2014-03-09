class RemoveVolumeFromMinerals < ActiveRecord::Migration
  def up
    remove_column :minerals, :volume
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
