FactoryBot.define do
  #  id            :integer          not null, primary key
  #  item_id       :integer          not null
  #  esi_id        :integer
  #  location_id   :integer
  #  region_id     :integer
  #  character_id  :integer
  #  price         :decimal(12, 2)
  #  issued        :datetime
  #  duration      :integer
  #  volume_remain :integer
  #  volume_total  :integer
  #  buy_order     :boolean
  #

  factory :order do
    association :item
    association :character

    transient do
      region { FactoryBot.create(:region) }
    end

    sequence(:esi_id)
    location_id { 60_003_760 }
    region_id { region.id }
    price { 100.0 }
    issued { 1.day.ago }
    duration { 90 }
    volume_remain { 10 }
    volume_total { 10 }
    buy_order { false }
  end
end
