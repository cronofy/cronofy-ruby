require "oauth2"

module Cronofy
  class ApiKey
    def initialize(client, client_secret)
      @client = client
      @client_secret = client_secret
    end

    # Make a request with the API Key
    #
    # @param [Symbol] verb the HTTP request method
    # @param [String] path the HTTP URL path of the request
    # @param [Hash] opts the options to make the request with
    # @see Client#request
    def request(verb, path, opts = {}, &block)
      configure_authentication!(opts)
      opts = { snaky: false }.merge(opts)
      do_request { @client.request(verb, path, opts, &block) }
    end

    # Make a GET request with the API Key
    #
    # @see ApiKey#request
    def get(path, opts = {}, &block)
      request(:get, path, opts, &block)
    end

    # Make a POST request with the API Key
    #
    # @see ApiKey#request
    def post(path, opts = {}, &block)
      request(:post, path, opts, &block)
    end

    # Make a PUT request with the API Key
    #
    # @see ApiKey#request
    def put(path, opts = {}, &block)
      request(:put, path, opts, &block)
    end

    # Make a PATCH request with the API Key
    #
    # @see ApiKey#request
    def patch(path, opts = {}, &block)
      request(:patch, path, opts, &block)
    end

    private

    def headers
      {'Authorization' => "Bearer #{@client_secret}"}
    end

    def configure_authentication!(opts)
      opts[:headers] ||= {}
      opts[:headers].merge!(headers)
    end

    def do_request(&block)
      if blank?(@client_secret)
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
