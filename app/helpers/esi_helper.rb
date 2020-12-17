module ESIHelper
  ESI_URL = 'https://login.eveonline.com/v2/oauth/authorize'.freeze
  LOGIN_IMAGE_URL = 'https://web.ccpgamescdn.com/eveonlineassets/developers/eve-sso-login-white-small.png'.freeze
  SCOPES = [
    'esi-markets.read_character_orders.v1',
    'esi-markets.read_corporation_orders.v1',
    'esi-markets.structure_markets.v1',
    'esi-planets.manage_planets.v1',
    'esi-planets.read_customs_offices.v1'
  ].freeze
  DEFAULT_PARAMS = {
    response_type: 'code',
    redirect_uri: Rails.application.routes.url_helpers.login_url,
    client_id: ENV['ESI_CLIENT_ID'],
    scope: SCOPES.join(' '),
    state: Time.now.to_i
  }.freeze

  def esi_login_button
    link_to(esi_login_url) { esi_login_image }
  end

  def esi_login_url(custom_params = {})
    uri = URI(ESI_URL)
    uri.query = DEFAULT_PARAMS.merge(custom_params).to_query
    uri.to_s
  end

  private

  def esi_login_image
    image_tag LOGIN_IMAGE_URL, alt: 'LOG IN with EVE Online'
  end
end
