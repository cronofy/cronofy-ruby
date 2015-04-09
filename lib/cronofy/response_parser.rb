require 'json'

module Cronofy
  class ResponseParser
    def initialize(response)
      @response = response
    end

    def parse_collection(collection_attribute, collection_type)
      hash = parse_json

      hash[collection_attribute].map { |item| collection_type.new(item) }
    end

    def parse_one(attribute, type)
      hash = parse_json

      type.new(hash[attribute])
    end

    def parse_json(type = nil)
      hash = JSON.parse(@response.body)

      if type
        type.new(hash)
      else
        hash
      end
    end
  end
end
