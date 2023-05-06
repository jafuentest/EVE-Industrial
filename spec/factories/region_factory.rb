FactoryBot.define do
  #  id               :integer          not null, primary key
  #  name             :string           not null
  #  constellation_id :integer          not null
  #  region_id        :integer          not null
  #

  factory :region do
    add_attribute(:name) { 'Region Name' }
  end
end
