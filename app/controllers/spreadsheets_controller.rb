class SpreadsheetsController < ApplicationController
  require 'nokogiri'
  
  def mining
    @systems = System.all
    @variations = []
    if params.has_key? :system
      sort_options = ['price', 'raw_revenue', 'refine_revenue', 'refining_gain', 'name']
      sort_column = (sort_options.include? params[:sort]) ? params[:sort] : 'id'
      system = params[:system]
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
      
      Variation.all.each do |var|
        variation = { :id => var.id, :name => var.name }
        variation[:price] = ore_prices[var.central_id]
        variation[:raw_revenue] = var.raw_revenue(ore_prices[var.central_id], sale_tax)
        variation[:refine_revenue] = var.refine_revenue(1, ore_prices, sale_tax)
        if variation[:price] == 0
          variation[:refining_gain] = 0
        else
          variation[:refining_gain] = (variation[:refine_revenue] / variation[:raw_revenue] - 1) * 100
        end
        @variations << variation
      end
      
      @variations.sort_by! { |v| v[sort_column.to_sym] }
      @variations.reverse! unless ['id', 'name'].include? sort_column
    end
  end
end
