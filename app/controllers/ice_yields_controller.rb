class IceYieldsController < ApplicationController
  # GET /ice_yields
  # GET /ice_yields.json
  def index
    @ice_ores = IceOre.all
    @ice_products = IceProduct.all
    @ice_yields = IceYield.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ice_yields }
    end
  end
end
