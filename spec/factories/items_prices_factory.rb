FactoryBot.define do
  #  star_id    :integer          not null
  #  item_id    :integer          not null
  #  item_type  :string           not null
  #  buy_price  :decimal(12, 2)
  #  sell_price :decimal(12, 2)
  #

  factory :items_prices do
    association :star
    association :item

    buy_price { 90.5 }
    sell_price { 100.5 }
  end
end
