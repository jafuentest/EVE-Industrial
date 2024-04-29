FactoryBot.define do
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

  factory :user
end
