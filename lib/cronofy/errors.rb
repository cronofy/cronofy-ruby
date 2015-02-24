module Cronofy

  class APIError < StandardError
    attr_reader :response

    def initialize(message, response=nil)
      super(message)
      @response = response
    end

    def body
      response.body if response
    end
  end

  class NotFoundError < APIError

  end

  class AuthorizationFailureError < APIError

  end

  class InvalidRequestError < APIError

  end

  class TooManyRequestsError < APIError

  end

  class UnknownError < APIError

  end

end