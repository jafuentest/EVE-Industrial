# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  esi_refresh_token      :string
#  esi_auth_token         :string
#  esi_expires_on         :datetime
#  character_id           :bigint
#  character_name         :string
#  character_portrait     :string
#  scopes                 :string
#  token_type             :string
#  owner_hash             :string
#  role                   :string
#  email                  :string
#  encrypted_password     :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable

  has_many :characters, dependent: :destroy
  has_many :industry_jobs, through: :characters
  has_many :orders, through: :characters

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

  def self.add_character(code, user_id)
    auth_response = ESI.authenticate(code)
    verification_data = ESI.verify_access_token(auth_response['access_token'])

    Character.find_or_initialize_by(character_id: verification_data['CharacterID']).tap do |c|
      c.user_id = user_id
      c.esi_auth_token = auth_response['access_token']
      c.esi_refresh_token = auth_response['refresh_token']
      c.verification_data = verification_data
      c.save!
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

  def remember_me
    super.nil? ? true : super
  end

  def update_market_orders
    characters.each do |character|
      Order.where(character_id: character.id).delete_all
      Order.update_character_orders(character)
    end
  end

  def update_industry_jobs
    characters.each do |character|
      IndustryJob.update_character_industry_jobs(character)
    end
  end

  protected

  def password_required?
    false
  end

  def email_required?
    false
  end
end
