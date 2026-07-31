class API::V1::CountsController < API::V1::BaseController
  def show
    render json: current_user.counters
  end
end
