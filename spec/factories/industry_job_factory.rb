FactoryBot.define do
  #  id                :integer          not null, primary key
  #  character_id      :integer
  #  blueprint_id      :integer
  #  blueprint_type_id :integer
  #  product_type_id   :integer
  #  activity_id       :integer
  #  station_id        :integer
  #  installer_id      :integer
  #  start_date        :datetime
  #  end_date          :datetime
  #  runs              :integer
  #  licensed_runs     :integer
  #  probability       :decimal(5, 4)
  #  status            :string
  #

  factory :industry_job do
    sequence(:id)

    association :character
    association :output, factory: :item

    blueprint_id { rand(1_000_000) }
    blueprint_type_id { rand(1_000_000) }
    activity_id { 1 }
    station_id { rand(1_000_000) }
    installer_id { rand(1_000_000) }
    runs { 1 }
    licensed_runs { 1 }
    probability { nil }
    status { 'active' }
    start_date { 1.hour.ago }
    end_date { 1.hour.from_now }

    trait :invention do
      activity_id { 8 }
      probability { 0.3562 }
    end

    trait :completed do
      start_date { 2.hours.ago }
      end_date { 1.hour.ago }
    end
  end
end
