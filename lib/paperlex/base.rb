module Paperlex
  class Base < Hashie::Dash
    class << self
      def post(*attrs)
        JSON.parse(RestClient.post(*attrs))
      end
    end
  end
end
