class AddSecurityToSystems < ActiveRecord::Migration
  def change
    add_column :systems, :security, :float
  end
end
