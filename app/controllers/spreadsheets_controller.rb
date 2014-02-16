class SpreadsheetsController < ApplicationController
  require 'nokogiri'
  
  def mining
    if (params.has_key? :region) && !params[:region].empty?
      price_list = []
      ore_ids = Variation.pluck(:central_id)
      mineral_ids = Mineral.pluck(:central_id)
      items = ore_ids.clone.concat(mineral_ids).join(',')
      
      # Retrieve user specific data
      
      station_yield = params[:station_yield]
      refinery_tax = params[:refinery_tax]
      skills = { :special_processing_skills => {} }
      skills[:refining_skill] = params[:refining_skill]
      skills[:refinery_efficiency_skill] = params[:refinery_efficiency_skill]
      params[:processing_skills].each do |k,v|
        skill_name = '%s_processing_skill' % k
        skills[k] = v
        cookies[skill_name] = v # Also save to cookie
      end
      
      # Save in cookies
      cookies[:region] = params[:region]
      cookies[:system] = params[:system]
      cookies[:refinery_tax] = params[:refinery_tax]
      cookies[:station_yield] = params[:station_yield]
      cookies[:refining_skill] = params[:refining_skill]
      cookies[:refinery_efficiency_skill] = params[:refinery_efficiency_skill]
      
      # Request information from eve-central and parse it to an array
      if params[:system].empty?
        region = Region.find params[:region]
        request = 'http://api.eve-central.com/api/marketstat?typeid=%s&regionlimit=%s' % [items, region.central_id]
        @params = { :region => region.id }
        @location = '%s Region' % region.name
      else
        region = Region.find params[:region]
        system = System.find params[:system]
        request = 'http://api.eve-central.com/api/marketstat?typeid=%s&usesystem=%s' % [items, system.central_id]
        @params = { :region => region.id, :system => system.id }
        @location = '%s System' % system.name
      end
      xml = Curl.get(request).body_str
      xml_doc  = Nokogiri::XML(xml)
      percentiles = xml_doc.xpath("/evec_api/marketstat/type/buy/percentile")
      
      # Dump the prices array into the hashes used for revenue calculation
      ore_prices = { }
      mineral_prices = { }
      percentiles.each do |percentile|
        item_id = percentile.parent.parent['id'].to_i
        if ore_ids.include? item_id
          ore_prices [item_id] = percentile.text.to_f
        else
          mineral_prices [item_id] = percentile.text.to_f
        end
      end
      
      # Retrieve the information to show about each ore variation
      @variations = []
      Variation.all.each do |var|
        variation = { :id => var.id, :name => var.name }
        variation[:price] = ore_prices[var.central_id]
        variation[:raw_revenue] = var.raw_revenue(ore_prices[var.central_id])
        refining_results = var.refine_revenue(mineral_prices, station_yield, skills, refinery_tax)
        variation[:refine_revenue] = refining_results[:revenue]
        variation[:refine_yield] = refining_results[:yield]
        if variation[:price] == 0
          variation[:refining_gain] = 0
        else
          variation[:refining_gain] = (variation[:refine_revenue] / variation[:raw_revenue] - 1) * 100
        end
        @variations << variation
      end
    end
    
    # Set initial values for input fields
    @ores = Ore.all
    @regions = Region.all
    @region = cookies[:region]
    @systems = @region.nil? ? nil : Region.find(@region).systems
    @system = cookies[:system]
    @station_yield = cookies[:station_yield]
    @refining_skill = cookies[:refining_skill]
    @refinery_efficiency_skill = cookies[:refinery_efficiency_skill]
    @refinery_tax = cookies[:refinery_tax]
    @processing_skills = {}
    @ores.each do |o|
      skill_name = '%s_processing_skill' % o.name
      @processing_skills[o.id] = cookies[skill_name]
    end
  end
end
