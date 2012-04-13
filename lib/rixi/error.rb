module Rixi
  module Error
    class APIError < StandardError
      attr_reader :response
      def initialize(msg, response = nil)
        super(msg)
        @response = response
      end
    end
  end
end
