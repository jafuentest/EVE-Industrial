class IceOresController < ApplicationController
  # GET /ice_ores
  # GET /ice_ores.json
  def index
    @ice_ores = IceOre.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ice_ores }
    end
  end
  
  # GET /ice_ores/1
  # GET /ice_ores/1.json
  def show
    @ice_ore = IceOre.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ice_ore }
    end
  end
  
  # GET /ice_ores/1/edit
  def edit
    @ice_ore = IceOre.find(params[:id])
  end
  
  # PUT /ice_ores/1
  # PUT /ice_ores/1.json
  def update
    @ice_ore = IceOre.find(params[:id])
    
    respond_to do |format|
      if @ice_ore.update_attributes(params[:ice_ore])
        format.html { redirect_to @ice_ore, notice: 'Ice ore was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ice_ore.errors, status: :unprocessable_entity }
      end
    end
  end
end
