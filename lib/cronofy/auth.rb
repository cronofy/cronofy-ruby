require "oauth2"

module Cronofy
  class Auth
    API_URL = 'https://api.cronofy.com'

    attr_reader :access_token

    def initialize(client_id, client_secret, token, refresh_token=nil)
      @client = OAuth2::Client.new(client_id, client_secret, site: API_URL)
      @access_token = OAuth2::AccessToken.new(@client, token, { refresh_token: refresh_token })
    end

    def user_auth_link(redirect_uri)
      url = @client.auth_code.authorize_url(
        :redirect_uri => redirect_uri,
        :response_type => 'code'
      )
      "#{url}&scope=list_calendars read_events create_event delete_event"
    end

    def get_token_from_code(code, redirect_uri)
      @client.auth_code.get_token(code, :redirect_uri => redirect_uri).token
    end

    # Public: Refreshes the access token
    # Returns Hash of token elements to allow client to update in local store for user
    def refresh!
      @access_token = access_token.refresh!
      {
        access_token: @access_token.token,
        refresh_token: @access_token.refresh_token,
        expires_in: @access_token.expires_in,
        expires_at: @access_token.expires_at
      }
    end

  end
end