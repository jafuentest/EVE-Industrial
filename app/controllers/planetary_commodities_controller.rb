class PlanetaryCommoditiesController < ApplicationController
  skip_before_filter :is_admin, only: [:index, :show]
  
  # GET /planetary_commodities/check_central_ids
  def check_central_ids
    @results = []
    PlanetaryCommodity.all.each do |planetary_commoditiy|
      request = 'http://api.eve-central.com/api/quicklook?typeid=%s' % [planetary_commodities.central_id]
      xml = Curl.get(request).body_str
      xml_doc  = Nokogiri::XML(xml)
      ec_name = xml_doc.xpath('/evec_api/quicklook/itemname').text
      result = { :name => planetary_commoditiy.name, :ec_name => ec_name, :match => planetary_commoditiy.name == ec_name }
      @results << result
    end
  end
  
  # GET /planetary_commodities
  # GET /planetary_commodities.json
  def index
    @commodities = PlanetaryCommodity.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @commodities }
    end
  end
  
  # GET /planetary_commodities/1
  # GET /planetary_commodities/1.json
  def show
    @planetary_commodity = PlanetaryCommodity.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @planetary_commodity }
    end
  end
  
  # GET /planetary_commodities/1/edit
  def edit
    @planetary_commodity = PlanetaryCommodity.find(params[:id])
  end
  
  # PUT /planetary_commodities/1
  # PUT /planetary_commodities/1.json
  def update
    @planetary_commodity = PlanetaryCommodity.find(params[:id])
    
    respond_to do |format|
      if @planetary_commodity.update_attributes(params[:planetary_commodity])
        format.html { redirect_to @planetary_commodity, notice: 'Planetary commodity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @planetary_commodity.errors, status: :unprocessable_entity }
      end
    end
  end
end
