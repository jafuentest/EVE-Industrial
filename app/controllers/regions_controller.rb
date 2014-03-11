class RegionsController < ApplicationController
  skip_before_filter :is_admin, only: [:index, :show]
  
  # GET /regions
  # GET /regions.json
  def index
    @regions = Region.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @regions }
    end
  end
  
  # GET /regions/1
  # GET /regions/1.json
  def show
    @region = Region.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @region }
    end
  end
  
  # GET /regions/1/edit
  def edit
    @region = Region.find(params[:id])
  end
  
  # PUT /regions/1
  # PUT /regions/1.json
  def update
    @region = Region.find(params[:id])
    
    respond_to do |format|
      if @region.update_attributes(params[:region])
        format.html { redirect_to @region, notice: 'Region was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end
end
