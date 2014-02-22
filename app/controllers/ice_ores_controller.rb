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

  # GET /ice_ores/new
  # GET /ice_ores/new.json
  def new
    @ice_ore = IceOre.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ice_ore }
    end
  end

  # GET /ice_ores/1/edit
  def edit
    @ice_ore = IceOre.find(params[:id])
  end

  # POST /ice_ores
  # POST /ice_ores.json
  def create
    @ice_ore = IceOre.new(params[:ice_ore])

    respond_to do |format|
      if @ice_ore.save
        format.html { redirect_to @ice_ore, notice: 'Ice ore was successfully created.' }
        format.json { render json: @ice_ore, status: :created, location: @ice_ore }
      else
        format.html { render action: "new" }
        format.json { render json: @ice_ore.errors, status: :unprocessable_entity }
      end
    end
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

  # DELETE /ice_ores/1
  # DELETE /ice_ores/1.json
  def destroy
    @ice_ore = IceOre.find(params[:id])
    @ice_ore.destroy

    respond_to do |format|
      format.html { redirect_to ice_ores_url }
      format.json { head :no_content }
    end
  end
end
