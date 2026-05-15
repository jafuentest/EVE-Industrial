FactoryBot.define do
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
  #

  factory :character do
    sequence(:character_id)

    association :user

    esi_refresh_token { "esi_refresh_token#{character_id}" }
    esi_auth_token { "esi_auth_token#{character_id}" }
    esi_expires_on { DateTime.now + 10.minutes }

    character_name { "Factory Character#{character_id}" }
    character_portrait { "https://images.evetech.net/characters/#{character_id}/portrait?tenant=tranquility&size=64" }

    scopes { 'esi-markets.read_character_orders.v1 esi-markets.read_corporation_orders.v1' }
    token_type { 'Character' }
    owner_hash { "owner_hash#{character_id}" }

    trait :without_verification_data do
      character_name { nil }
      scopes { nil }
      token_type { nil }
      owner_hash { nil }
      esi_expires_on { nil }
    end
  end
end
