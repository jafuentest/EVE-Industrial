class CreateYields < ActiveRecord::Migration
  def change
    create_table :yields do |t|
      t.integer :quantity
      t.integer :bonus
    end
  end
end
