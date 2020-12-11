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

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    return nil unless res.is_a?(Net::HTTPOK)

    JSON.parse(res.body)
  end

  def self.fetch_character_portrait(character_id)
    uri = URI("#{ESI_BASE_URL}/characters/#{character_id}/portrait/")
    req = Net::HTTP::Get.new(uri)

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    JSON.parse(res.body)
  end

  def self.fetch_character_planets(user)
    uri = URI("#{ESI_BASE_URL}/characters/#{user.character_id}/planets/")
    req = request_from_uri(uri, user.auth_token)

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    JSON.parse(res.body)
  end

  def self.fetch_planets_details(user, planets)
    planets.map do |planet|
      planet.merge(fetch_planet_details(user, planet['planet_id']))
    end
  end

  def self.fetch_character_market_orders(user)
    uri = URI("#{ESI_BASE_URL}/characters/#{user.character_id}/orders/")
    req = request_from_uri(uri, user.auth_token)

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    JSON.parse(res.body)
  end

  private_class_method def self.fetch_planet_details(user, planet_id)
    uri = URI("#{ESI_BASE_URL}/characters/#{user.character_id}/planets/#{planet_id}")
    req = request_from_uri(uri, user)

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

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
