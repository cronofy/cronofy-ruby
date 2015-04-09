require 'json'

module Cronofy
  class ResponseParser
    def initialize(response)
      @response = response
    end

    def parse_json(collection_attribute = nil, collection_type = nil)
      hash = JSON.parse(@response.body)

      if collection_attribute
        hash[collection_attribute].map { |item| collection_type.new(item) }
      else
        hash
      end
    end
  end
end
