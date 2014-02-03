class MineralsController < ApplicationController
  # GET /minerals
  # GET /minerals.json
  def index
    @minerals = Mineral.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @minerals }
    end
  end

  # GET /minerals/1
  # GET /minerals/1.json
  def show
    @mineral = Mineral.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mineral }
    end
  end

  # GET /minerals/new
  # GET /minerals/new.json
  def new
    @mineral = Mineral.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mineral }
    end
  end

  # GET /minerals/1/edit
  def edit
    @mineral = Mineral.find(params[:id])
  end

  # POST /minerals
  # POST /minerals.json
  def create
    @mineral = Mineral.new(params[:mineral])

    respond_to do |format|
      if @mineral.save
        format.html { redirect_to @mineral, notice: 'Mineral was successfully created.' }
        format.json { render json: @mineral, status: :created, location: @mineral }
      else
        format.html { render action: "new" }
        format.json { render json: @mineral.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /minerals/1
  # PUT /minerals/1.json
  def update
    @mineral = Mineral.find(params[:id])

    respond_to do |format|
      if @mineral.update_attributes(params[:mineral])
        format.html { redirect_to @mineral, notice: 'Mineral was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mineral.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /minerals/1
  # DELETE /minerals/1.json
  def destroy
    @mineral = Mineral.find(params[:id])
    @mineral.destroy

    respond_to do |format|
      format.html { redirect_to minerals_url }
      format.json { head :no_content }
    end
  end
end
