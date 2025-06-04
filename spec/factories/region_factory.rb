FactoryBot.define do
  #  id               :integer          not null, primary key
  #  name             :string           not null
  #  constellation_id :integer          not null
  #  region_id        :integer          not null
  #

  factory :region do
    sequence(:id)
    add_attribute(:name) { "Region Name #{id}" }
  end
end
