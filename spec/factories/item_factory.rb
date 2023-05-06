FactoryBot.define do
  #  id               :integer          not null, primary key
  #  name             :string           not null
  #

  factory :item do
    add_attribute(:name) { 'Item Name' }
  end
end
