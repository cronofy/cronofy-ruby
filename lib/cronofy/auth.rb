require "oauth2"

module Cronofy
  # Internal: Class for dealing with authentication and authorization issues.
  class Auth
    attr_reader :access_token

    def initialize(client_id, client_secret, token = nil, refresh_token = nil)
      @auth_client = OAuth2::Client.new(client_id, client_secret, site: ::Cronofy.app_url, connection_opts: { headers: { "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}" } })
      @api_client = OAuth2::Client.new(client_id, client_secret, site: ::Cronofy.api_url, connection_opts: { headers: { "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}" } })

      set_access_token(token, refresh_token) if token
    end

    # Internal: generate a URL for authorizing the application with Cronofy
    #
    # redirect_uri    String, the URI to return to after authorization
    # scope           Array of String, the scope requested
    # state           OAuth 2.0-specified state
    #
    # See http://www.cronofy.com/developers/api#authorization for reference.
    #
    # Returns the URL as a String.
    def user_auth_link(redirect_uri, scope, state = nil)
      params = {
        redirect_uri: redirect_uri,
        response_type: 'code',
        scope: scope.join(' '),
        state: state
      }.delete_if { |key, value| value.nil? }
      @auth_client.auth_code.authorize_url(params)
    end

    def get_token_from_code(code, redirect_uri)
      do_request do
        @access_token = @auth_client.auth_code.get_token(code, redirect_uri: redirect_uri)
        Credentials.new(@access_token)
      end
    end

    # Internal: Refreshes the access token
    # Returns Hash of token elements to allow client to update in local store for user
    def refresh!
      do_request do
        @access_token = access_token.refresh!
        Credentials.new(@access_token)
      end
    end

    def set_access_token_from_auth_token(auth_token)
      set_access_token(auth_token.token, auth_token.refresh_token)
    end

    def set_access_token(token, refresh_token)
      @access_token = OAuth2::AccessToken.new(@api_client, token, refresh_token: refresh_token)
    end

    # Internal: Revokes the refresh token and corresponding access tokens.
    #
    # Returns nothing.
    def revoke!
      do_request do
        body = {
          client_id: @api_client.id,
          client_secret: @api_client.secret,
          token: access_token.refresh_token,
        }

        @api_client.request(:post, "/oauth/token/revoke", body: body)
        @access_token = nil
      end
    end

    private

    def do_request(&block)
      block.call
    rescue OAuth2::Error => e
      raise Errors.map_error(e)
    end
  end
end
