class VariationsController < ApplicationController
  def add_yields
    @variation = Variation.find(params[:id])
    @minerals = Mineral.all
    
    if request.request_method == 'POST'
      @minerals.each do |mineral|
        y = Yield.find_by_mineral_id_and_variation_id(mineral.id, @variation.id)
        if params[mineral.id.to_s] == ''
          y.destroy unless y.nil?
        else
          y = Yield.new if y.nil?
          y.quantity = params[mineral.id.to_s]
          y.variation = @variation
          y.mineral = mineral
          y.save
        end
      end
      redirect_to @variation, :notice => 'Variation updated successfully'
    end
  end
  
  def check_central_ids
    variations = Variation.all
    @results = []
    variations.each do |variation|
      request = 'http://api.eve-central.com/api/quicklook?typeid=%s' % [variation.central_id]
      xml = Curl.get(request).body_str
      xml_doc  = Nokogiri::XML(xml)
      ec_name = xml_doc.xpath("/evec_api/quicklook/itemname").text
      result = { :name => variation.name, :ec_name => ec_name, :match => variation.name == ec_name }
      @results << result
    end
  end
  
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

  # GET /variations/1/edit
  def edit
    @variation = Variation.find(params[:id])
    @ores = Ore.all
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
end
