FactoryBot.define do
  #  id               :integer          not null, primary key
  #  name             :string           not null
  #  region_id        :integer          not null
  #

  factory :constellation do
    association :region
    add_attribute(:name) { 'Constellation Name' }
  end
end
