class VariationsController < ApplicationController
  # GET /variations
  # GET /variations.json
  def index
    @variations = Variation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @variations }
    end
  end

  # GET /variations/1
  # GET /variations/1.json
  def show
    @variation = Variation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @variation }
    end
  end

  # GET /variations/new
  # GET /variations/new.json
  def new
    @variation = Variation.new
    @ores = Ore.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @variation }
    end
  end

  # GET /variations/1/edit
  def edit
    @variation = Variation.find(params[:id])
    @ores = Ore.all
  end

  # POST /variations
  # POST /variations.json
  def create
    @variation = Variation.new(params[:variation])

    respond_to do |format|
      if @variation.save
        format.html { redirect_to @variation, notice: 'Variation was successfully created.' }
        format.json { render json: @variation, status: :created, location: @variation }
      else
        format.html { render action: "new" }
        format.json { render json: @variation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /variations/1
  # PUT /variations/1.json
  def update
    @variation = Variation.find(params[:id])

    respond_to do |format|
      if @variation.update_attributes(params[:variation])
        format.html { redirect_to @variation, notice: 'Variation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @variation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /variations/1
  # DELETE /variations/1.json
  def destroy
    @variation = Variation.find(params[:id])
    @variation.destroy

    respond_to do |format|
      format.html { redirect_to variations_url }
      format.json { head :no_content }
    end
  end
end
