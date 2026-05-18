FactoryBot.define do
  #  id               :integer          not null, primary key
  #  name             :string           not null
  #

  factory :item do
    sequence(:id)
    add_attribute(:name) { "Item Name #{id}" }
  end
end
