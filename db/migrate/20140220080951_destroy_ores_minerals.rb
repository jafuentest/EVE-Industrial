class DestroyOresMinerals < ActiveRecord::Migration
  def up
    drop_table :ores_minerals
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
