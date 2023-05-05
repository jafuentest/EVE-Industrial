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
    association :user

    trait :without_verification_data do
      character_name { nil }
      scopes { nil }
      token_type { nil }
      owner_hash { nil }
      esi_expires_on { nil }
    end
  end
end
