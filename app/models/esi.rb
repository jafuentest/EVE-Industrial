class ESI
  AUTH_BASE_URL = 'https://login.eveonline.com'
  OAUTH_URI = URI("#{AUTH_BASE_URL}/v2/oauth/token")
  VERIFY_URI = URI("#{AUTH_BASE_URL}/oauth/verify")

  ESI_BASE_URL = 'https://esi.evetech.net/latest'
  PORTRAIT_URL =

  def self.authenticate(code, refresh: false)
    endpoint = refresh ? :refresh_token_request : :fetch_token_request

    res = Net::HTTP.start(OAUTH_URI.hostname, OAUTH_URI.port, use_ssl: true) do |http|
      request = method(endpoint).call(code)
      http.request(request)
    end

    return nil unless res.is_a?(Net::HTTPOK)

    JSON.parse(res.body)
  end

  def self.verify_access_token(access_token)
    req = Net::HTTP::Get.new(VERIFY_URI)
    req['Authorization'] = "Bearer #{access_token}"

    res = Net::HTTP.start(VERIFY_URI.hostname, VERIFY_URI.port, use_ssl: true) do |http|
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

  def self.fetch_planet_stuff

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
    Net::HTTP::Post.new(OAUTH_URI).tap do |req|
      req['Host'] = 'login.eveonline.com'
      req.content_type = 'application/x-www-form-urlencoded'
      req.basic_auth(ENV['ESI_CLIENT_ID'], ENV['ESI_CLIENT_SECRET'])
    end
  end
end
