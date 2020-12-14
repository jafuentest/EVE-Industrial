class Order < ApplicationRecord
  belongs_to :item

  ESI_ATTRIBUTES = %w[location_id price issued duration].freeze

  def placed_in_npc_station
    location_id < 100_000_000
  end
end
