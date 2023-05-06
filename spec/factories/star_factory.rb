FactoryBot.define do
  #  id               :integer          not null, primary key
  #  name             :string           not null
  #  constellation_id :integer          not null
  #  region_id        :integer          not null
  #

  factory :star do
    association :constellation
    association :region
    add_attribute(:name) { 'Star System Name' }
  end
end
