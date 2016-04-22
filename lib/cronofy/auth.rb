require "oauth2"

module Cronofy
  # Internal: Class for dealing with authentication and authorization issues.
  class Auth
    attr_reader :access_token

    def initialize(client_id, client_secret, token = nil, refresh_token = nil)
      @client_credentials_missing = blank?(client_id) || blank?(client_secret)

      @auth_client = OAuth2::Client.new(client_id, client_secret, site: ::Cronofy.app_url, connection_opts: { headers: { "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}" } })
      @api_client = OAuth2::Client.new(client_id, client_secret, site: ::Cronofy.api_url, connection_opts: { headers: { "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}" } })

      set_access_token(token, refresh_token) if token
    end

    # Internal: generate a URL for authorizing the application with Cronofy
    #
    # redirect_uri - A String specifing the URI to return the user to once they
    #                have completed the authorization steps.
    # options      - The Hash options used to refine the selection
    #                (default: {}):
    #                :scope - Array of scopes describing the access to request
    #                         from the user to the users calendars (required).
    #                :state - Array of states to retain during the OAuth
    #                         authorization process (optional).
    #
    # See http://www.cronofy.com/developers/api#authorization for reference.
    #
    # Returns the URL as a String.
    def user_auth_link(redirect_uri, options = {})
      raise ArgumentError.new(":scope is required") unless options[:scope]

      params = options.merge(redirect_uri: redirect_uri, response_type: 'code')

      # Reformat params as needed
      params.delete(:state) if params[:state].nil?
      params[:scope] = params[:scope].join(' ')

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
      if @client_credentials_missing
        raise CredentialsMissingError.new("OAuth client_id and client_secret must be set")
      end
      block.call
    rescue OAuth2::Error => e
      raise Errors.map_error(e)
    end

    def blank?(value)
      value.nil? || value.strip.empty?
    end
  end
end
