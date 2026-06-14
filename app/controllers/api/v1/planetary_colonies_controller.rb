class API::V1::PlanetaryColoniesController < API::V1::BaseController
  def index
    grouped = current_user.characters.includes(:planetary_colonies).map do |character|
      {
        character: {
          id: character.id,
          character_name: character.character_name
        },
        colonies: character.planetary_colonies.map { |colony| colony_json(colony) }
      }
    end
    render json: grouped
  end

  def update
    current_user.update_planetary_colonies
    head :ok
  end

  private

  def colony_json(colony)
    schematic_ids = colony.factories.pluck(:schematic_id).uniq
    end_products = PlanetaryCommodity.where(schematic_id: schematic_ids)
      .pluck(:id, :name)
      .map { |id, name| { id:, name: } }

    {
      id: colony.id,
      planet_id: colony.planet_id,
      planet_type: colony.planet_type,
      upgrade_level: colony.upgrade_level,
      isk_per_day: colony.isk_per_day,
      expiry_time: colony.expiry_time,
      end_products:
    }
  end
end
