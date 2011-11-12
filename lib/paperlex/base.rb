module Paperlex
  class Base < Hashie::Dash
    class << self
      def post(url, *attrs)
        JSON.parse(RestClient.post("#{Paperlex.base_url}/#{url}", *attrs))
      end
    end
  end
end
