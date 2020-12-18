class CreateCharacters < ActiveRecord::Migration[6.0]
  def change
    create_table :characters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :esi_refresh_token
      t.string :esi_auth_token
      t.datetime :esi_expires_on

      t.bigint :character_id
      t.string :character_name
      t.string :character_portrait
      t.string :scopes
      t.string :token_type
      t.string :owner_hash

      t.timestamps
    end
  end
end
