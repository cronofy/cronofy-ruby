require "oauth2"

module Cronofy
  class Auth
    API_URL = 'https://api.cronofy.com'
    APP_URL = 'https://app.cronofy.com'

    def initialize(client_id, client_secret, token)
      @client = OAuth2::Client.new(client_id, client_secret, site: API_URL)
      @token = token
    end

    def user_auth_link(redirect_uri)
      url = @client.auth_code.authorize_url(
        :redirect_uri => redirect_uri,
        :response_type => 'code'
      ).gsub(API_URL, APP_URL)
      "#{url}&scope=list_calendars read_events create_event delete_event"
    end

    def get_token_from_code(code, redirect_uri)
      @client.auth_code.get_token(code, :redirect_uri => redirect_uri).token
    end

    def request
      @request ||= OAuth2::AccessToken.new(@client, @token)
    end
  end
end