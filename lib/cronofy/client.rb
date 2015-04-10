module Cronofy
  class Client
    def initialize(client_id, client_secret, token = nil, refresh_token = nil)
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
      response = get("/v1/calendars")
      parse_collection(Calendar, "calendars", response)
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

      body[:start] = to_iso8601(body[:start])
      body[:end] = to_iso8601(body[:end])

      post("/v1/calendars/#{calendar_id}/events", body)
    end
    alias_method :upsert_event, :create_or_update_event

    # Public : Returns a paged list of events within a given time period,
    #          that you have not created, across all of a users calendars.
    #          see http://www.cronofy.com/developers/api#read-events
    #
    # from            - The minimum Date from which to return events.
    # to              - The Date to return events up until.
    # tzid            - A String representing a known time zone identifier from the
    #                   IANA Time Zone Database (default: Etc/UTC)
    # include_deleted - A Boolean specifying whether events that have been deleted
    #                   should included or excluded from the results.
    # include_moved   - A Boolean specifying whether events that have ever existed
    #                   within the given window should be included or excluded from
    #                   the results.
    # last_modified   - The Time that events must be modified on or after
    #                   in order to be returned.
    #
    # Returns paged Hash of events
    def read_events(opts = {})
      params = READ_EVENTS_DEFAULT_PARAMS.merge(opts)

      READ_EVENTS_TIME_PARAMS.select { |tp| params.key?(tp) }.each do |tp|
        params[tp] = to_iso8601(params[tp])
      end

      response = get("/v1/events", params: params)
      parse_json(PagedEventsResult, response)
    end

    # Public : Returns a paged list of events given a page URL.
    #          Page URLs are obtained from read_events requests and
    #          get_events_page requests (response.pages.next_page)
    #          see http://www.cronofy.com/developers/api#read-events
    #
    # page_url - the url of a page of Read Events results
    #
    # Returns paged Hash of events
    def get_events_page(page_url)
      page_path = page_url.sub(::Cronofy.api_url, '')

      response = get(page_path)
      parse_json(PagedEventsResult, response)
    end

    # Public : Deletes an event from the specified calendar
    #          see http://www.cronofy.com/developers/api#delete-event
    #
    # calendar_id   - String Cronofy ID for the calendar containing the event
    # event_id      - String client ID for the event
    #
    # Returns nothing
    def delete_event(calendar_id, event_id)
      delete("/v1/calendars/#{calendar_id}/events", event_id: event_id)
    end

    # Public : Creates a notification channel with a callback URL
    #
    # callback_url  - String URL with the callback
    #
    # Returns Hash of channel
    def create_channel(callback_url)
      response = post("/v1/channels", callback_url: callback_url)
      parse_json(Channel, "channel", response)
    end

    # Public : Lists the channels of the user
    #
    # Returns Hash of channels
    def list_channels
      response = get("/v1/channels")
      parse_collection(Channel, "channels", response)
    end

    # Public : Generate the authorization URL to send the user to in order to generate
    #          and authorization code in order for an access_token to be issued
    #          see http://www.cronofy.com/developers/api#authorization
    #
    # redirect_uri  - String URI to return the user to once authorization process completed
    # scope         - Array of scopes describing access required to the users calendars (default: all scopes)
    #
    # Returns String
    def user_auth_link(redirect_uri, scope = nil)
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

    READ_EVENTS_DEFAULT_PARAMS = { tzid: "Etc/UTC" }.freeze

    READ_EVENTS_TIME_PARAMS = %i{
      from
      to
      last_modified
    }.freeze

    def do_request(&block)
      begin
        block.call
      rescue OAuth2::Error => e
        raise Errors.map_oauth2_error(e)
      end
    end

    def get(url, opts = {})
      do_request do
        access_token!.get(url, opts)
      end
    end

    def post(url, body)
      do_request do
        access_token!.post(url, json_request_args(body))
      end
    end

    def delete(url, body)
      do_request do
        access_token!.delete(url, json_request_args(body))
      end
    end

    def parse_collection(type, attr, response)
      ResponseParser.new(response).parse_collection(type, attr)
    end

    def parse_json(type, attr = nil, response)
      ResponseParser.new(response).parse_json(type, attr)
    end

    def json_request_args(body_hash)
      {
        body: JSON.generate(body_hash),
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      }
    end

    def to_iso8601(value)
      case value
      when NilClass
        nil
      when Time
        value.getutc.iso8601
      else
        value.iso8601
      end
    end
  end

  # Alias for backwards compatibility
  # Deprectated will be removed
  class Cronofy < Client
  end
end
