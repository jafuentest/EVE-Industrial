class IceProductsController < ApplicationController
  # GET /ice_products
  # GET /ice_products.json
  def index
    @ice_products = IceProduct.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ice_products }
    end
  end

  # GET /ice_products/1
  # GET /ice_products/1.json
  def show
    @ice_product = IceProduct.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ice_product }
    end
  end

  # GET /ice_products/new
  # GET /ice_products/new.json
  def new
    @ice_product = IceProduct.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ice_product }
    end
  end

  # GET /ice_products/1/edit
  def edit
    @ice_product = IceProduct.find(params[:id])
  end

  # POST /ice_products
  # POST /ice_products.json
  def create
    @ice_product = IceProduct.new(params[:ice_product])

    respond_to do |format|
      if @ice_product.save
        format.html { redirect_to @ice_product, notice: 'Ice product was successfully created.' }
        format.json { render json: @ice_product, status: :created, location: @ice_product }
      else
        format.html { render action: "new" }
        format.json { render json: @ice_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ice_products/1
  # PUT /ice_products/1.json
  def update
    @ice_product = IceProduct.find(params[:id])

    respond_to do |format|
      if @ice_product.update_attributes(params[:ice_product])
        format.html { redirect_to @ice_product, notice: 'Ice product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ice_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ice_products/1
  # DELETE /ice_products/1.json
  def destroy
    @ice_product = IceProduct.find(params[:id])
    @ice_product.destroy

    respond_to do |format|
      format.html { redirect_to ice_products_url }
      format.json { head :no_content }
    end
  end
end
