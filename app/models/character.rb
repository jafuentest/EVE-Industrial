# == Schema Information
#
# Table name: characters
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  esi_refresh_token  :string
#  esi_auth_token     :string
#  esi_expires_on     :datetime
#  character_id       :bigint
#  character_name     :string
#  character_portrait :string
#  scopes             :string
#  token_type         :string
#  owner_hash         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  reauth_required    :boolean          default(FALSE), not null
#
class Character < ApplicationRecord
  include CorporationLookup

  belongs_to :user
  has_many :industry_jobs, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :planetary_colonies, dependent: :destroy

  def verification_data=(verification_data)
    self.character_name = verification_data['CharacterName']
    self.scopes = verification_data['Scopes']
    self.token_type = verification_data['TokenType']
    self.owner_hash = verification_data['CharacterOwnerHash']
    self.esi_expires_on = DateTime.parse(verification_data['ExpiresOn'])
  end

  def auth_token
    return esi_auth_token unless token_expired?

    auth_response = ESI.authenticate(esi_refresh_token, refresh: true)
    return mark_reauth_required if auth_response.nil?

    apply_refreshed_token(auth_response)
    esi_auth_token
  rescue StandardError => e
    Rails.logger.warn("ESI token refresh failed for character #{id}: #{e.message}")
    nil
  end

  def wallet_balance(force: false)
    cached_balance = Rails.cache.fetch(wallet_balance_cache_key, expires_in: 5.minutes, skip_nil: true, force:) do
      balance = ESI.fetch_character_wallet(self)
      balance if balance.is_a?(Numeric)
    end
    cached_balance || 0
  rescue StandardError => e
    Rails.logger.warn("ESI wallet lookup failed for character #{character_id}: #{e.message}")
    0
  end

  def avatar
    return character_portrait if character_portrait.present?

    portraits = ESI.fetch_character_portrait(character_id)
    update(character_portrait: portraits['px64x64'])
    character_portrait
  end

  private

  def wallet_balance_cache_key
    "wallet_balance/#{character_id}"
  end

  def token_expired?
    # Treat tokens as expired 5 seconds earlier
    DateTime.now.utc + 5.seconds >= esi_expires_on
  end

  def apply_refreshed_token(auth_response)
    assign_attributes(
      esi_refresh_token: auth_response['refresh_token'],
      esi_auth_token: auth_response['access_token'],
      esi_expires_on: DateTime.now.utc + auth_response['expires_in'].to_i.seconds,
      reauth_required: false
    )
    save! if persisted?
  end

  def mark_reauth_required
    update!(reauth_required: true) if persisted?
    nil
  end
end
