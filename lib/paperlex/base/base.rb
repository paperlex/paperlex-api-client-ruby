module Paperlex
  class Base < Hashie::Dash
    property :uuid, :required => true

    class << self
      def get(url, *attrs)
        JSON.parse(RestClient.get("#{Paperlex.base_url}/#{url}?token=#{Paperlex.token}", *attrs))
      end

      def post(url, attrs = {})
        JSON.parse(RestClient.post("#{Paperlex.base_url}/#{url}", attrs.merge(:token => Paperlex.token)))
      end

      def put(url, attrs = {})
        JSON.parse(RestClient.put("#{Paperlex.base_url}/#{url}", attrs.merge(:token => Paperlex.token)))
      end

      def delete(url, attrs = {})
        JSON.parse(RestClient.delete("#{Paperlex.base_url}/#{url}", attrs.merge(:token => Paperlex.token)))
      end
    end

    def initialize(uuid, attrs = {})
      super(uuid.is_a?(Hash) ? uuid.merge(attrs) : attrs.merge(:uuid => uuid))
    end
  end
end
