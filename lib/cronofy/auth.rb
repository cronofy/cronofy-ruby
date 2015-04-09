require "oauth2"

module Cronofy
  class Auth
    class Credentials
      attr_reader :access_token,
                  :expires_at,
                  :expires_in,
                  :refresh_token,
                  :scope

      def initialize(oauth_token)
        @access_token = oauth_token.token
        @expires_at = oauth_token.expires_at
        @expires_in = oauth_token.expires_in
        @refresh_token = oauth_token.refresh_token
        @scope = oauth_token.params['scope']
      end

      def to_hash
        {
          access_token: access_token,
          refresh_token: refresh_token,
          expires_in: expires_in,
          expires_at: expires_at,
          scope: scope,
        }
      end
    end

    attr_reader :access_token

    def initialize(client_id, client_secret, token=nil, refresh_token=nil)
      @auth_client = OAuth2::Client.new(client_id, client_secret, site: ::Cronofy.app_url)
      @api_client = OAuth2::Client.new(client_id, client_secret, site: ::Cronofy.api_url)

      set_access_token(token, refresh_token) if token
    end

    # Public: generate a URL for authorizing the application with Cronofy
    #
    # redirect_uri    String, the URI to return to after authorization
    # scope           Array of String, the scope requested
    #                 Default: [read_account, list_calendars, read_events, create_event, delete_event]
    #                 see: http://www.cronofy.com/developers/api#authorization
    #
    # Returns String URL
    def user_auth_link(redirect_uri, scope=nil)
      scope ||= %w{read_account list_calendars read_events create_event delete_event}

      @auth_client.auth_code.authorize_url(:redirect_uri => redirect_uri, :response_type => 'code', :scope => scope.join(' '))
    end

    def get_token_from_code(code, redirect_uri)
      do_request do
        @access_token = @auth_client.auth_code.get_token(code, :redirect_uri => redirect_uri)
        Credentials.new(@access_token)
      end
    end

    # Public: Refreshes the access token
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
      @access_token = OAuth2::AccessToken.new(@api_client, token, { refresh_token: refresh_token })
    end

    private

    def do_request(&block)
      block.call
    rescue OAuth2::Error => e
      raise Errors.map_oauth2_error(e)
    end
  end
end
