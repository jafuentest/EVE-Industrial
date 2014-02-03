class CreateVariations < ActiveRecord::Migration
  def change
    create_table :variations do |t|
      t.string :name
    end
  end
end
