class YieldsController < ApplicationController
  # GET /yields
  # GET /yields.json
  def index
    @yields = Yield.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @yields }
    end
  end

  # GET /yields/1
  # GET /yields/1.json
  def show
    @yield = Yield.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @yield }
    end
  end

  # GET /yields/new
  # GET /yields/new.json
  def new
    @yield = Yield.new
    @variations = Variation.all
    @minerals = Mineral.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @yield }
    end
  end

  # GET /yields/1/edit
  def edit
    @yield = Yield.find(params[:id])
    @variations = Variation.all
    @minerals = Mineral.all
  end

  # POST /yields
  # POST /yields.json
  def create
    @yield = Yield.new(params[:yield])

    respond_to do |format|
      if @yield.save
        format.html { redirect_to @yield, notice: 'Yield was successfully created.' }
        format.json { render json: @yield, status: :created, location: @yield }
      else
        format.html { render action: "new" }
        format.json { render json: @yield.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /yields/1
  # PUT /yields/1.json
  def update
    @yield = Yield.find(params[:id])

    respond_to do |format|
      if @yield.update_attributes(params[:yield])
        format.html { redirect_to @yield, notice: 'Yield was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @yield.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /yields/1
  # DELETE /yields/1.json
  def destroy
    @yield = Yield.find(params[:id])
    @yield.destroy

    respond_to do |format|
      format.html { redirect_to yields_url }
      format.json { head :no_content }
    end
  end
end
