require "cronofy/version"
require "cronofy/errors"
require "cronofy/types"
require "cronofy/api_key"
require "cronofy/auth"
require "cronofy/time_encoding"
require "cronofy/client"
require "cronofy/response_parser"

require 'base64'
require 'json'
require 'openssl'

module Cronofy
  def self.default_data_centre
    default_data_center
  end

  def self.default_data_centre=(value)
    default_data_center= value
  end

  def self.default_data_center
    @default_data_center || ENV['CRONOFY_DATA_CENTER'] || ENV['CRONOFY_DATA_CENTRE']
  end

  def self.default_data_center=(value)
    @default_data_center = value
  end

  def self.api_url(data_center_override)
    if data_center_override
      api_url_for_data_center(data_center_override)
    else
      ENV['CRONOFY_API_URL'] || api_url_for_data_center(default_data_center)
    end
  end

  def self.api_url=(value)
    @api_url = value
  end

  def self.api_url_for_data_centre
    api_url_for_data_center
  end

  def self.api_url_for_data_center(dc)
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

  def self.app_url(data_center_override)
    if data_center_override
      app_url_for_data_center(data_center_override)
    else
      ENV['CRONOFY_APP_URL'] || app_url_for_data_center(default_data_center)
    end
  end

  def self.app_url=(value)
    @app_url = value
  end

  def self.app_url_for_data_centre(dc)
    app_url_for_data_center(dc)
  end

  def self.app_url_for_data_center(dc)
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
