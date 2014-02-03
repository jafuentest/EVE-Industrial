class OresController < ApplicationController
  # GET /ores
  # GET /ores.json
  def index
    @ores = Ore.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ores }
    end
  end

  # GET /ores/1
  # GET /ores/1.json
  def show
    @ore = Ore.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ore }
    end
  end

  # GET /ores/new
  # GET /ores/new.json
  def new
    @ore = Ore.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ore }
    end
  end

  # GET /ores/1/edit
  def edit
    @ore = Ore.find(params[:id])
  end

  # POST /ores
  # POST /ores.json
  def create
    @ore = Ore.new(params[:ore])

    respond_to do |format|
      if @ore.save
        format.html { redirect_to @ore, notice: 'Ore was successfully created.' }
        format.json { render json: @ore, status: :created, location: @ore }
      else
        format.html { render action: "new" }
        format.json { render json: @ore.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ores/1
  # PUT /ores/1.json
  def update
    @ore = Ore.find(params[:id])

    respond_to do |format|
      if @ore.update_attributes(params[:ore])
        format.html { redirect_to @ore, notice: 'Ore was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ore.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ores/1
  # DELETE /ores/1.json
  def destroy
    @ore = Ore.find(params[:id])
    @ore.destroy

    respond_to do |format|
      format.html { redirect_to ores_url }
      format.json { head :no_content }
    end
  end
end
