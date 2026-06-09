class AddReauthRequiredToCharacters < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :reauth_required, :boolean, default: false, null: false
  end
end
