require "cronofy/version"
require "cronofy/auth"
require "cronofy/response_parser"
require "cronofy/errors"

module Cronofy
  class Cronofy

    def initialize(client_id, client_secret, token=nil, refresh_token=nil)
      @auth = Auth.new(client_id, client_secret, token, refresh_token)
    end

    def access_token!
      raise CredentialsMissingError.new unless @auth.access_token
      @auth.access_token
    end

    # Public : Lists the calendars or the user across all of the calendar accounts
    #          see http://www.cronofy.com/developers/api#calendars
    #
    # Returns Hash of calendars
    def list_calendars
      response = do_request { access_token!.get("/v1/calendars")  }
      ResponseParser.new(response).parse_json
    end

    # Public : Creates or updates an existing event that matches the event_id, in the calendar
    #          see: http://www.cronofy.com/developers/api#upsert-event
    #          aliased as upsert_event
    #
    # calendar_id   - String Cronofy ID for the the calendar to contain the event
    # event         - Hash describing the event with symbolized keys.
    #                 :event_id String client identifier for event NOT Cronofy's
    #                 :summary String
    #                 :start Time
    #                 :end Time
    #
    # Returns nothing
    def create_or_update_event(calendar_id, event)
      body = event.dup
      body[:start] = event[:start].utc.iso8601
      body[:end] = event[:end].utc.iso8601

      headers = {
        'Content-Type' => 'application/json'
      }

      do_request { access_token!.post("/v1/calendars/#{calendar_id}/events", { body: body.to_json, headers: headers }) }
    end
    alias_method :upsert_event, :create_or_update_event

    # Public : Deletes an event from the specified calendar
    #          see http://www.cronofy.com/developers/api#delete-event
    #
    # calendar_id   - String Cronofy ID for the calendar containing the event
    # event_id      - String client ID for the event
    #
    # Returns nothing
    def delete_event(calendar_id, event_id)
      params = { event_id: event_id }

      do_request { access_token!.delete("/v1/calendars/#{calendar_id}/events", { params: params }) }
    end

    # Public : Generate the authorization URL to send the user to in order to generate
    #          and authorization code in order for an access_token to be issued
    #          see http://www.cronofy.com/developers/api#authorization
    #
    # redirect_uri  - String URI to return the user to once authorization process completed
    # scope         - Array of scopes describing access required to the users calendars (default: all scopes)
    #
    # Returns String
    def user_auth_link(redirect_uri, scope=nil)
      @auth.user_auth_link(redirect_uri, scope)
    end

    # Public : Returns the access_token for a given code and redirect_uri pair
    #          see http://www.cronofy.com/developers/api#token-issue
    #
    # code          - String code returned to redirect_uri after authorization
    # redirect_uri  - String URI returned to
    #
    # Returns Cronofy::Credentials
    def get_token_from_code(code, redirect_uri)
      @auth.get_token_from_code(code, redirect_uri)
    end

    # Public : Refreshes the access_token and periodically the refresh_token for authorization
    #          see http://www.cronofy.com/developers/api#token-refresh
    #
    # Returns Cronofy::Credentials
    def refresh_access_token
      @auth.refresh!
    end

  private

    ERROR_MAP = {
      401 => AuthorizationFailureError,
      404 => NotFoundError,
      422 => InvalidRequestError,
      429 => TooManyRequestsError
    }

    def do_request(&block)
      begin
        block.call
      rescue OAuth2::Error => e
        error_class = ERROR_MAP.fetch(e.response.status, UnknownError)
        raise error_class.new(e.response.headers['status'], e.response)
      end
    end

  end

end
