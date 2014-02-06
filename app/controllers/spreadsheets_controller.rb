class SpreadsheetsController < ApplicationController
  require 'nokogiri'
  
  def mining
    system = params.has_key?(:system) ? params[:system] : 30002187
    sale_tax = 1 - ((params.has_key?(:tax) ? params[:tax] : 0) / 100)
    price_list = []
    ore_ids = Variation.pluck(:central_id)
    mineral_ids = Mineral.pluck(:central_id)
    items = ore_ids.concat(mineral_ids).join(',')
    
    request = 'http://api.eve-central.com/api/marketstat?typeid=%s&usesystem=%s' % [items, system]

    xml = Curl.get(request).body_str
    xml_doc  = Nokogiri::XML(xml)
    percentiles = xml_doc.xpath("/evec_api/marketstat/type/buy/percentile")
    
    ore_prices = { }
    mineral_prices = { }
    percentiles.each do |percentile|
      if ore_ids.include? percentile.parent.parent['id'].to_i
        ore_prices [percentile.parent.parent['id'].to_i] = percentile.text.to_f
      else
        mineral_prices [percentile.parent.parent['id'].to_i] = percentile.text.to_f
      end
    end
    
    @variations = []
    Variation.all.each do |var|
      variation = { :object => var }
      variation[:price] = ore_prices[var.central_id]
      variation[:raw_revenue] = var.raw_revenue(ore_prices[var.central_id], sale_tax)
      variation[:refine_revenue] = var.refine_revenue(1, ore_prices, sale_tax)
      variation[:refining_gain] = variation[:refine_revenue] - variation[:raw_revenue]
      @variations << variation
    end
  end
end
