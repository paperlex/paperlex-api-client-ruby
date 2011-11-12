module Paperlex
  class Base < Hashie::Dash
    property :uuid, :required => true

    class << self
      def post(url, *attrs)
        JSON.parse(RestClient.post("#{Paperlex.base_url}/#{url}", *attrs))
      end

      def get(url, *attrs)
        JSON.parse(RestClient.get("#{Paperlex.base_url}/#{url}", *attrs))
      end
    end

    def initialize(uuid, attrs = {})
      super(uuid.is_a?(Hash) ? uuid.merge(attrs) : attrs.merge(uuid: uuid))
    end
  end
end
