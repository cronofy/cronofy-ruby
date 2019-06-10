require 'json'

module Cronofy
  # Internal: Class for dealing with the parsing of API responses.
  class ResponseParser
    def initialize(response)
      @response = response
    end

    def parse_collections(attribute_collection_types)
      attribute_collection_types.each do |attribute, type|
        return parse_collection(type, attribute.to_s) if json_hash[attribute.to_s]
      end

      raise "No mapped attributes for response - #{json_hash.keys}"
    end

    def parse_collection(type, attribute = nil)
      target = parsing_target(attribute)
      target.map { |item| type.new(item) }
    end

    def parse_json(type, attribute = nil)
      target = parsing_target(attribute)
      type.new(target)
    end

    def json
      json_hash.dup
    end

    private

    def json_hash
      @json_hash ||= JSON.parse(@response.body)
    end

    def parsing_target(attribute)
      if attribute
        json_hash[attribute]
      else
        json_hash
      end
    end
  end
end
