require "oauth2"

module Cronofy
  # Internal: Class for dealing with authentication and authorization issues.
  class Auth
    attr_reader :access_token
    attr_reader :api_key
    attr_reader :api_client

    def initialize(options = {})
      access_token = options[:access_token]
      client_id = options[:client_id]
      client_secret = options[:client_secret]
      data_centre = options[:data_centre]
      refresh_token = options[:refresh_token]

      @client_credentials_missing = blank?(client_id) || blank?(client_secret)

      @auth_client = OAuth2::Client.new(client_id, client_secret, site: ::Cronofy.app_url(data_centre), connection_opts: { headers: { "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}" } })
      @api_client = OAuth2::Client.new(client_id, client_secret, site: ::Cronofy.api_url(data_centre), connection_opts: { headers: { "User-Agent" => "Cronofy Ruby #{::Cronofy::VERSION}" } })

      set_access_token(access_token, refresh_token) if access_token || refresh_token
      set_api_key(client_secret) if client_secret
    end

    # Internal: generate a URL for authorizing the application with Cronofy
    #
    # redirect_uri - A String specifing the URI to return the user to once they
    #                have completed the authorization steps.
    # options      - The Hash options used to refine the selection
    #                (default: {}):
    #                :scope - Array or String of scopes describing the access to
    #                         request from the user to the users calendars
    #                         (required).
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

      if params[:scope].respond_to?(:join)
        params[:scope] = params[:scope].join(' ')
      end

      @auth_client.auth_code.authorize_url(params)
    end

    def get_token_from_code(code, redirect_uri)
      do_request do
        @access_token = @auth_client.auth_code.get_token(code, redirect_uri: redirect_uri)
        Credentials.new(@access_token)
      end
    end

    # Internal: Refreshes the access token
    #
    # Returns Hash of token elements to allow client to update in local store
    # for user
    #
    # Raises Cronofy::CredentialsMissingError if no credentials available.
    def refresh!
      raise CredentialsMissingError.new("No credentials to refresh") unless access_token
      raise CredentialsMissingError.new("No refresh_token provided") unless access_token.refresh_token

      do_request do
        @access_token = access_token.refresh!
        Credentials.new(@access_token)
      end
    end

    # Internal: Obtains access to an application calendar
    #
    # application_calendar_id - A String to identify the application calendar
    #                           which is to be accessed.
    #
    # Returns Hash of token elements to allow client to update in local store
    # for user
    #
    # Raises Cronofy::CredentialsMissingError if no credentials available.
    def application_calendar(application_calendar_id)
      do_request do
        body = {
          client_id: @api_client.id,
          client_secret: @api_client.secret,
          application_calendar_id: application_calendar_id,
        }

        @response = @api_client.request(:post, "/v1/application_calendars", body: body)
        Credentials.new(OAuth2::AccessToken.from_hash(@api_client, @response.parsed))
      end
    end

    def set_access_token_from_auth_token(auth_token)
      set_access_token(auth_token.token, auth_token.refresh_token)
    end

    def set_access_token(token, refresh_token)
      @access_token = OAuth2::AccessToken.new(@api_client, token, refresh_token: refresh_token)
    end

    def set_api_key(client_secret)
      @api_key = ApiKey.new(@api_client, client_secret)
    end

    # Internal: Revokes the refresh token and corresponding access tokens.
    #
    # Returns nothing.
    #
    # Raises Cronofy::CredentialsMissingError if no credentials available.
    def revoke!
      raise CredentialsMissingError.new("No credentials to revoke") unless access_token

      do_request do
        body = {
          client_id: @api_client.id,
          client_secret: @api_client.secret,
          token: access_token.refresh_token || access_token.token,
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
