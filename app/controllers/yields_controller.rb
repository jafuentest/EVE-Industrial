class YieldsController < ApplicationController
  skip_before_filter :is_admin
  
  # GET /yields
  # GET /yields.json
  def index
    @variations = Variation.all
    @minerals = Mineral.all
    @yields = Yield.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @yields }
    end
  end
end
