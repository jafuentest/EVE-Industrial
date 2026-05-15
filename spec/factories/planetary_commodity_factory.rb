FactoryBot.define do
  #  id           :integer          not null, primary key
  #  schematic_id :integer
  #  name         :string           not null
  #  tier         :integer          not null
  #  volume       :decimal(5, 2)
  #  batch_size   :integer          not null
  #  input        :text
  #

  factory :planetary_commodity do
    sequence(:id)

    name { "Planetary Commodity #{id}" }
    tier { 1 }
    volume { 0.01 }
    batch_size { 3000 }
    schematic_id { nil }
    input { nil }
  end
end
