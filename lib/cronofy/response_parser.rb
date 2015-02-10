require 'json'

module Cronofy
  class ResponseParser
    def initialize(response)
      @response = response
    end

    def parse_json
      JSON.parse @response.body
    end
  end
end