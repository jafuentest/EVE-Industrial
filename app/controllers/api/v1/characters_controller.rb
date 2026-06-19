class API::V1::CharactersController < API::V1::BaseController
  def index
    render json: current_user.characters.map { |c| character_json(c) }
  end

  def destroy
    character = current_user.characters.find(params.expect(:id))
    character.destroy
    head :ok
  end

  private

  def character_json(character)
    {
      id: character.id,
      character_id: character.character_id,
      character_name: character.character_name,
      avatar: character.avatar,
      reauth_required: character.reauth_required
    }
  end
end
