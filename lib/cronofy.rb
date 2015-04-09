require "cronofy/version"
require "cronofy/errors"
require "cronofy/auth"
require "cronofy/client"
require "cronofy/response_parser"
require 'json'

module Cronofy
  def self.api_url
    @api_url ||= (ENV['CRONOFY_API_URL'] || "https://api.cronofy.com")
  end

  def self.api_url=(value)
    @api_url = value
  end

  def self.app_url
    @app_url ||= (ENV['CRONOFY_APP_URL'] || "https://app.cronofy.com")
  end

  def self.app_url=(value)
    @app_url = value
  end
end
