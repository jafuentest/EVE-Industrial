FactoryBot.define do
  #  id               :integer          not null, primary key
  #  name             :string           not null
  #  constellation_id :integer          not null
  #  region_id        :integer          not null
  #

  factory :star do
    sequence(:id)
    association :constellation
    region { constellation.region }
    add_attribute(:name) { "Star System Name #{id}" }
  end
end
