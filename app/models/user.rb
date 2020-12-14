class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable

  has_many :orders

  def self.find_or_register(code)
    auth_response = ESI.authenticate(code)
    verification_data = ESI.verify_access_token(auth_response['access_token'])

    find_or_initialize_by(character_id: verification_data['CharacterID']).tap do |u|
      u.esi_auth_token = auth_response['access_token']
      u.esi_refresh_token = auth_response['refresh_token']
      u.verification_data = verification_data
      u.save!
    end
  end

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

  def update_market_orders
    Order.where(user_id: id).delete_all
    Order.update_character_orders(self)
  end

  protected

  def password_required?
    false
  end

  def email_required?
    false
  end
end
