class SpreadsheetsController < ApplicationController
  require 'nokogiri'
  
  def mining
    system = params.has_key?(:system) ? params[:system] : 30002187
    sale_tax = 1 - ((params.has_key?(:tax) ? params[:tax] : 0) / 100)
    @ores = []
    Ore.all.each do |ore|
      ore_dict = { :name => ore.name}
      ore_dict[:variations] = []
      
      ore.variations.each do |variation|
        request = 'http://api.eve-central.com/api/quicklook?typeid=%s&usesystem=%s' % [variation.central_id, system]
        xml = Curl.get(request).body_str
        xml_doc  = Nokogiri::XML(xml)
        price_list = xml_doc.xpath("/evec_api/quicklook/buy_orders/order/price")
        prices = []
        price_list.to_a.each do |price|
          prices << price.text.to_f
        end
        max_price = prices.max
    
        variation = { :object => variation }
        variation[:raw_revenue] = (1000/ore.volume)*max_price*sale_tax
        ore_dict[:variations] << variation
      end
      @ores << ore_dict
    end
  end
end
