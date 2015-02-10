require "cronofy/version"
require "cronofy/auth"
require "cronofy/response_parser"

module Cronofy
  class Cronofy

    def initialize(client_id, client_secret, token = false)
      @auth = Auth.new(client_id, client_secret, token)
    end

    def list_calendars
      ResponseParser.new(request(:get, 'calendars')).parse_json
    end

    def create_or_update_event(calendar_id, event_data)
      event_data[:start] = event_data[:start].utc.iso8601
      event_data[:end] = event_data[:end].utc.iso8601
      request(:post, "calendars/#{calendar_id}/events", event_data)
    end

    def delete_event(calendar_id, event_id)
      request(:delete, "calendars/#{calendar_id}/events", event_id: event_id)
    end

    def user_auth_link(redirect_uri)
      @auth.user_auth_link(redirect_uri)
    end

    def get_token_from_code(code, redirect_uri)
      @auth.get_token_from_code(code, redirect_uri)
    end

    private

    def request(method, path, params = {})
      @auth.request.send(method, "/v1/#{path}", params: params)
    end

  end

end
