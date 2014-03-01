class SpreadsheetsController < ApplicationController
  require 'nokogiri'
  
  def planetary_interaction
    if (params.has_key? :region) && !params[:region].empty?
      items = PlanetaryCommodity.pluck(:central_id).join(',')
      
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
      xml_doc = Nokogiri::XML(xml)
      percentiles = xml_doc.xpath("/evec_api/marketstat/type/buy/percentile")
      
      # Dump the prices array into the hashes used for revenue calculation
      prices = { }
      percentiles.each do |percentile|
        item_id = percentile.parent.parent['id'].to_i
        prices [item_id] = percentile.text.to_f
      end
      
      @resources = []
      PlanetaryCommodity.where(:tier => 0).each do |pc|
        resource = { :name => pc.name }
        resource[:price] = prices[pc.central_id]
        @resources << resource
      end
      
      @materials = []
      PlanetaryCommodity.where(:tier => 1).each do |pc|
        resource = { :name => pc.name }
        resource[:price] = prices[pc.central_id]
        @materials << resource
      end
      
      @commodities = []
      PlanetaryCommodity.where(:tier => 2).each do |pc|
        resource = { :name => pc.name }
        resource[:price] = prices[pc.central_id]
        @commodities << resource
      end
    end
    
    # Set initial values for input fields
    @regions = Region.all
    @region = cookies[:region]
    @systems = @region.nil? ? nil : Region.find(@region).systems
    @system = cookies[:system]
  end
  
  def refining
    if (params.has_key? :region) && !params[:region].empty?
      ore_ids = Variation.pluck(:central_id)
      mineral_ids = Mineral.pluck(:central_id)
      items = ore_ids.clone.concat(mineral_ids).join(',')
      
      # Retrieve user specific data
      station_yield = params[:station_yield]
      refinery_tax = params[:refinery_tax]
      market_tax = params[:market_tax]
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
      cookies[:market_tax] = params[:market_tax]
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
      xml_doc = Nokogiri::XML(xml)
      buy_percentiles = xml_doc.xpath("/evec_api/marketstat/type/buy/percentile")
      sell_percentiles = xml_doc.xpath("/evec_api/marketstat/type/sell/percentile")
      
      # Dump the prices array into the hashes used for revenue calculation
      ore_prices = { }
      sell_percentiles.each do |percentile|
        item_id = percentile.parent.parent['id'].to_i
        ore_prices [item_id] = percentile.text.to_f
      end
      
      mineral_prices = { }
      buy_percentiles.each do |percentile|
        item_id = percentile.parent.parent['id'].to_i
        mineral_prices [item_id] = percentile.text.to_f
      end
      
      @minerals = []
      Mineral.all.each do |min|
        mineral = { :id => min.id, :name => min.name }
        mineral[:price] = mineral_prices[min.central_id]
        @minerals << mineral
      end
      
      # Retrieve the information to show about each ore variation
      @variations = []
      Variation.all.each do |var|
        variation = { :id => var.id, :name => var.name }
        variation[:price] = ore_prices[var.central_id]
        refining_results = var.refine_revenue(mineral_prices, station_yield, skills, refinery_tax)
        variation[:efficiency] = refining_results[:efficiency]
        if variation[:price] == 0
          variation[:refine_revenue] = -100 # lower than any possible value
        else
          cost = var.raw_revenue(ore_prices[var.central_id])
          profit = refining_results[:revenue] * (1 - market_tax.to_f/100)
          profit -= cost
          profit /= cost
          variation[:refine_revenue] = profit
        end
        @variations << variation
      end
      
      @variations.sort_by! { |v| v[:refine_revenue] }.reverse!
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
    @market_tax = cookies[:market_tax]
    @processing_skills = {}
    @ores.each do |o|
      skill_name = '%s_processing_skill' % o.name
      @processing_skills[o.id] = cookies[skill_name]
    end
  end
  
  def ore_mining
    if (params.has_key? :region) && !params[:region].empty?
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
      xml_doc = Nokogiri::XML(xml)
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
        variation[:volume] = refining_results[:volume]
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
  
  def ice_mining
    if (params.has_key? :region) && !params[:region].empty?
      ore_ids = IceOre.pluck(:central_id)
      products_ids = IceProduct.pluck(:central_id)
      items = ore_ids.clone.concat(products_ids).join(',')
      
      # Retrieve user specific data
      station_yield = params[:station_yield]
      refinery_tax = params[:refinery_tax]
      skills = { }
      skills[:refining_skill] = params[:refining_skill]
      skills[:refinery_efficiency_skill] = params[:refinery_efficiency_skill]
      skills[:ice_processing_skill] = params[:ice_processing_skill]
      
      # Save in cookies
      cookies[:region] = params[:region]
      cookies[:system] = params[:system]
      cookies[:refinery_tax] = params[:refinery_tax]
      cookies[:station_yield] = params[:station_yield]
      cookies[:refining_skill] = params[:refining_skill]
      cookies[:refinery_efficiency_skill] = params[:refinery_efficiency_skill]
      cookies[:ice_processing_skill] = params[:ice_processing_skill]
      
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
      xml_doc = Nokogiri::XML(xml)
      percentiles = xml_doc.xpath("/evec_api/marketstat/type/buy/percentile")
      
      # Dump the prices array into the hashes used for revenue calculation
      ore_prices = { }
      product_prices = { }
      percentiles.each do |percentile|
        item_id = percentile.parent.parent['id'].to_i
        if ore_ids.include? item_id
          ore_prices [item_id] = percentile.text.to_f
        else
          product_prices [item_id] = percentile.text.to_f
        end
      end
      
      # Retrieve the information to show about each ore variation
      @ores = []
      IceOre.all.each do |ore|
        ore_hash = { :id => ore.id, :name => ore.name }
        ore_hash[:price] = ore_prices[ore.central_id]
        refining_results = ore.refine_revenue(product_prices, station_yield, skills, refinery_tax)
        ore_hash[:refine_revenue] = refining_results[:revenue]
        ore_hash[:refine_yield] = refining_results[:yield]
        ore_hash[:volume] = refining_results[:volume]
        if ore_hash[:price] == 0
          ore_hash[:refining_gain] = 0
        else
          ore_hash[:refining_gain] = (ore_hash[:refine_revenue] / ore_hash[:price] - 1) * 100
        end
        @ores << ore_hash
      end
    end
    
    # Set initial values for input fields
    @regions = Region.all
    @region = cookies[:region]
    @systems = @region.nil? ? nil : Region.find(@region).systems
    @system = cookies[:system]
    @station_yield = cookies[:station_yield]
    @refining_skill = cookies[:refining_skill]
    @refinery_efficiency_skill = cookies[:refinery_efficiency_skill]
    @refinery_tax = cookies[:refinery_tax]
  end
end
