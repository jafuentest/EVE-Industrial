class MineralsController < ApplicationController
  def check_eve_central_ids
    minerals = Mineral.all
    @results = []
    minerals.each do |mineral|
      request = 'http://api.eve-central.com/api/quicklook?typeid=%s' % [mineral.central_id]
      xml = Curl.get(request).body_str
      xml_doc  = Nokogiri::XML(xml)
      ec_name = xml_doc.xpath("/evec_api/quicklook/itemname").text
      result = { :name => mineral.name, :ec_name => ec_name, :match => mineral.name == ec_name }
      @results << result
    end
  end
  
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
  
  # GET /minerals/1/edit
  def edit
    @mineral = Mineral.find(params[:id])
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
end
