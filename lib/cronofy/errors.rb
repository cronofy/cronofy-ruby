module Cronofy
  module Errors

    class NotFound < StandardError

    end

    class AuthorizationFailure < StandardError

    end

    class UnknownError < StandardError
      attr_reader :body
      def initialize(message, body)
        @body = body
        super(message)
      end
    end
  end
end