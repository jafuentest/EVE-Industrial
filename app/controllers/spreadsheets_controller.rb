class SpreadsheetsController < ApplicationController
  require 'nokogiri'
  
  def mining
    system = params.has_key?(:system) ? params[:system] : 30002187
    sale_tax = 1 - ((params.has_key?(:tax) ? params[:tax] : 0) / 100)
    price_list = []
    vars = Variation.pluck(:central_id).join(',')
    
    request = 'http://api.eve-central.com/api/marketstat?typeid=%s&usesystem=%s' % [vars, system]

    xml = Curl.get(request).body_str
    xml_doc  = Nokogiri::XML(xml)
    percentiles = xml_doc.xpath("/evec_api/marketstat/type/buy/percentile")
    
    prices = { }
    percentiles.each do |percentile|
      prices [percentile.parent.parent['id'].to_i] = percentile.text.to_f
    end
    
    @ores = []
    Ore.all.each do |ore|
      ore_dict = { :name => ore.name}
      ore_dict[:variations] = []
      
      ore.variations.each do |var|
        max_price = 5
    
        variation = { :object => var }
        variation[:price] = prices[var.central_id]
        variation[:raw_revenue] = (1000/ore.volume)*prices[var.central_id]*sale_tax
        ore_dict[:variations] << variation
      end
      @ores << ore_dict
    end
  end
end
