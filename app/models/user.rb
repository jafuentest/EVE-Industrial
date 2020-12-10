class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable

  def self.find_or_register(code)
    auth_response = ESI.authenticate(code)
    data = ESI.verify_access_token(auth_response['access_token'])

    find_or_initialize_by(character_id: data['']).tap do |u|
      u.esi_auth_token = auth_response['access_token']
      u.esi_refresh_token = auth_response['refresh_token']
      u.esi_expires_on = DateTime.parse(data['ExpiresOn'])

      u.character_id = data['CharacterID']
      u.character_name = data['CharacterName']
      u.scopes = data['Scopes']
      u.token_type = data['TokenType']
      u.owner_hash = data['CharacterOwnerHash']
      u.save!
    end
  end

  def auth_token
    # Treat tokens as expired 5 seconds earlier
    expired_token = DateTime.now.utc + 5.seconds >= esi_expires_on
    return esi_auth_token unless expired_token

    auth_response = ESI.authenticate(esi_refresh_token, refresh: true)

    self.esi_refresh_token = auth_response['refresh_token']
    self.esi_auth_token = auth_response['access_token']
  end

  def avatar
    return character_portrait if character_portrait.present?

    portraits = ESI.fetch_character_portrait(character_id)
    update(character_portrait: portraits['px64x64'])
    character_portrait
  end

  protected

  def password_required?
    false
  end

  def email_required?
    false
  end
end
