class ESI
  AUTH_BASE_URL = 'https://login.eveonline.com'.freeze
  ESI_BASE_URL = 'https://esi.evetech.net/latest'.freeze

  def self.authenticate(code, refresh: false)
    endpoint = refresh ? :refresh_token_request : :fetch_token_request
    uri = URI("#{AUTH_BASE_URL}/v2/oauth/token")
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      request = method(endpoint).call(code)
      http.request(request)
    end

    return nil unless res.is_a?(Net::HTTPOK)

    JSON.parse(res.body)
  end

  def self.verify_access_token(access_token)
    uri = URI("#{AUTH_BASE_URL}/oauth/verify")
    req = request_from_uri(uri, access_token)
    parsed_response(uri, req)
  end

  # General Items
  def self.fetch_item_name(type_id)
    uri = URI("#{ESI_BASE_URL}/universe/types/#{type_id}/")
    req = Net::HTTP::Get.new(uri)
    parsed_response(uri, req)['name']
  end

  # Item Market
  def self.fetch_character_market_orders(character)
    uri = URI("#{ESI_BASE_URL}/characters/#{character.character_id}/orders/")
    req = request_from_uri(uri, character.auth_token)
    parsed_response(uri, req)
  end

  def self.fetch_citadel_orders(character, structure_id, page)
    uri = URI("https://esi.evetech.net/latest/markets/structures/#{structure_id}?page=#{page}")
    req = request_from_uri(uri, character.auth_token)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    body = JSON.parse(res.body)

    body.is_a?(Array) ? body : nil
  end

  def self.fetch_region_orders(region_id, item_id, buy_or_sell)
    uri = URI("#{ESI_BASE_URL}/markets/#{region_id}/orders/?order_type=#{buy_or_sell}&page=1&type_id=#{item_id}")
    req = request_from_uri(uri)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    body = JSON.parse(res.body)

    body.is_a?(Array) ? body : nil
  end

  # Industry
  def self.fetch_character_industry_jobs(character)
    uri = URI("https://esi.evetech.net/latest/characters/#{character.character_id}/industry/jobs/")
    req = request_from_uri(uri, character.auth_token)
    parsed_response(uri, req)
  end

  # Planetary Interaction (PI)
  def self.fetch_character_planets(character)
    uri = URI("#{ESI_BASE_URL}/characters/#{character.character_id}/planets/")
    req = request_from_uri(uri, character.auth_token)
    parsed_response(uri, req)
  end

  def self.fetch_planets_details(character, planets)
    planets.map do |planet|
      planet.merge(fetch_planet_details(character, planet['planet_id']))
    end
  end

  # User Data
  def self.fetch_character_portrait(character_id)
    uri = URI("#{ESI_BASE_URL}/characters/#{character_id}/portrait/")
    req = Net::HTTP::Get.new(uri)
    parsed_response(uri, req)
  end

  private_class_method def self.fetch_planet_details(character, planet_id)
    uri = URI("#{ESI_BASE_URL}/characters/#{character.character_id}/planets/#{planet_id}")
    req = request_from_uri(uri, character.auth_token)
    parsed_response(uri, req)
  end

  # Utility
  private_class_method def self.parsed_response(uri, req)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    JSON.parse(res.body)
  end

  private_class_method def self.request_from_uri(uri, access_token = nil)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{access_token}" if access_token.present?
    req['Accept'] = 'application/json'
    req
  end

  private_class_method def self.fetch_token_request(code)
    base_token_request.tap do |req|
      req.set_form_data(grant_type: 'authorization_code', code: code)
    end
  end

  private_class_method def self.refresh_token_request(code)
    base_token_request.tap do |req|
      req.set_form_data(grant_type: 'refresh_token', refresh_token: code)
    end
  end

  private_class_method def self.base_token_request
    uri = URI("#{AUTH_BASE_URL}/v2/oauth/token")
    Net::HTTP::Post.new(uri).tap do |req|
      req['Host'] = 'login.eveonline.com'
      req.content_type = 'application/x-www-form-urlencoded'
      req.basic_auth(ENV['ESI_CLIENT_ID'], ENV['ESI_CLIENT_SECRET'])
    end
  end
end
