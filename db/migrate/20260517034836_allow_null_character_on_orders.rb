class AllowNullCharacterOnOrders < ActiveRecord::Migration[7.0]
  def change
    change_column_null :orders, :character_id, true
  end
end
