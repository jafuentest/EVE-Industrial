class API::V1::SyncsController < API::V1::BaseController
  def create
    current_user.sync_from_esi
    render json: current_user.counters
  end
end
