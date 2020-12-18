class Character < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :nullify

  def verification_data=(verification_data)
    self.character_name = verification_data['CharacterName']
    self.scopes = verification_data['Scopes']
    self.token_type = verification_data['TokenType']
    self.owner_hash = verification_data['CharacterOwnerHash']
    self.esi_expires_on = DateTime.parse(verification_data['ExpiresOn'])
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
end
