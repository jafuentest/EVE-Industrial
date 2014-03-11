class SchematicsController < ApplicationController
  skip_before_filter :is_admin
  
  # GET /schematics
  # GET /schematics.json
  def index
    @commodities = PlanetaryCommodity.find(:all, :conditions => ['tier > 0'])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @schematics }
    end
  end
end
