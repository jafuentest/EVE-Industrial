module ESIHelper
  ESI_URL = 'https://login.eveonline.com/v2/oauth/authorize'.freeze
  LOGIN_IMAGE_URL = 'https://web.ccpgamescdn.com/eveonlineassets/developers/eve-sso-login-white-small.png'.freeze
  DEFAULT_PARAMS = {
    redirect_uri: Rails.application.routes.url_helpers.login_url,
    client_id: ENV['ESI_CLIENT_ID'],
    scope: 'esi-planets.manage_planets.v1 esi-planets.read_customs_offices.v1',
    state: 'state'
  }

  def esi_login_button
    link_to(esi_login_url) { esi_login_image }
  end

  private

  def esi_login_image
    image_tag LOGIN_IMAGE_URL, alt: 'LOG IN with EVE Online'
  end

  def esi_login_url(custom_params = {})
    uri = URI(ESI_URL)
    uri.query = DEFAULT_PARAMS.merge(custom_params).to_query
    uri.to_s
  end
end
