FactoryBot.define do
  #  character_id  :bigint           not null
  #  star_id       :bigint           not null
  #  planet_id     :bigint           not null
  #  planet_type   :string           not null
  #  upgrade_level :integer          not null
  #  extractors    :string           default("{}")
  #  factories     :string           default("{}")
  #  last_update   :datetime
  #

  factory :planetary_colony do
    association :character

    sequence(:planet_id)
    star_id { 30_000_142 }
    planet_type { 'barren' }
    upgrade_level { 3 }
    last_update { Time.zone.now }

    extractors do
      [
        {
          'expiry_time' => '2026-05-20T12:00:00Z',
          'extractor_details' => {
            'cycle_time' => 3600,
            'product_type_id' => 2268,
            'qty_per_cycle' => 100
          }
        }
      ]
    end

    factories do
      [
        { 'type_id' => 2473, 'schematic_id' => 65 }
      ]
    end
  end
end
