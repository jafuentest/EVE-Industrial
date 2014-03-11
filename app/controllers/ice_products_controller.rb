class IceProductsController < ApplicationController
  skip_before_filter :is_admin, only: [:index, :show]
  
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
  
  # GET /ice_products/1/edit
  def edit
    @ice_product = IceProduct.find(params[:id])
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
        format.html { render action: 'edit' }
        format.json { render json: @ice_product.errors, status: :unprocessable_entity }
      end
    end
  end
end
