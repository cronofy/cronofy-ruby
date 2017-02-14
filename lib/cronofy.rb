require "cronofy/version"
require "cronofy/errors"
require "cronofy/types"
require "cronofy/auth"
require "cronofy/client"
require "cronofy/response_parser"
require 'json'

module Cronofy
  def self.default_data_centre
    @default_data_centre || ENV['CRONOFY_DATA_CENTRE']
  end

  def self.default_data_centre=(value)
    @default_data_centre = value
  end

  def self.api_url(data_centre_override)
    if data_centre_override
      api_url_for_data_centre(data_centre_override)
    else
      ENV['CRONOFY_API_URL'] || api_url_for_data_centre(default_data_centre)
    end
  end

  def self.api_url=(value)
    @api_url = value
  end

  def self.api_url_for_data_centre(dc)
    @api_urls ||= Hash.new do |hash, key|
      if key.nil? || key.to_sym == :us
        url = "https://api.cronofy.com"
      else
        url = "https://api-#{key}.cronofy.com"
      end

      hash[key] = url.freeze
    end

    @api_urls[dc]
  end

  def self.app_url(data_centre_override)
    if data_centre_override
      app_url_for_data_centre(data_centre_override)
    else
      ENV['CRONOFY_APP_URL'] || app_url_for_data_centre(default_data_centre)
    end
  end

  def self.app_url=(value)
    @app_url = value
  end

  def self.app_url_for_data_centre(dc)
    @app_urls ||= Hash.new do |hash, key|
      if key.nil? || key.to_sym == :us
        url = "https://app.cronofy.com"
      else
        url = "https://app-#{key}.cronofy.com"
      end

      hash[key] = url.freeze
    end

    @app_urls[dc]
  end
end
