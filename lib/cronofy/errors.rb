module Cronofy
  class CronofyError < StandardError
  end

  class CredentialsMissingError < CronofyError
    def initialize(message=nil)
      super(message || "No credentials supplied")
    end
  end

  class APIError < CronofyError
    attr_reader :response

    def initialize(message, response=nil)
      super(message)
      @response = response
    end

    def body
      response.body if response
    end

    def headers
      response.headers if response
    end

    def inspect
      "<#{self.class.name} message=#{message} headers=#{headers.inspect} body=#{body}>"
    end
  end

  class BadRequestError < APIError
  end

  class NotFoundError < APIError
  end

  class AuthenticationFailureError < APIError
  end

  class AuthorizationFailureError < APIError
  end

  class InvalidRequestError < APIError
  end

  class TooManyRequestsError < APIError
  end

  class UnknownError < APIError
  end

  class Errors
    ERROR_MAP = {
      400 => BadRequestError,
      401 => AuthenticationFailureError,
      403 => AuthorizationFailureError,
      404 => NotFoundError,
      422 => InvalidRequestError,
      429 => TooManyRequestsError,
    }.freeze

    def self.map_oauth2_error(error)
      error_class = ERROR_MAP.fetch(error.response.status, UnknownError)
      raise error_class.new(error.response.headers['status'], error.response)
    end
  end
end
