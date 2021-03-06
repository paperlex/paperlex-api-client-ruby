module Paperlex
  class Base < Hashie::Dash
    property :uuid, :required => true

    class << self
      def parse(result)
        if result == "null"
          nil
        else
          JSON.parse(result)
        end
      end
      
      def [](uuid)
        new(uuid)
      end

      def get(url, attrs = {})
        parse(RestClient.get("#{Paperlex.base_url}/#{url}?#{attrs.merge(:token => Paperlex.token).to_query}"))
      end

      def post(url, attrs = {})
        parse(RestClient.post("#{Paperlex.base_url}/#{url}", attrs.merge(:token => Paperlex.token)))
      end

      def put(url, attrs = {})
        parse(RestClient.put("#{Paperlex.base_url}/#{url}", attrs.merge(:token => Paperlex.token)))
      end

      def delete(url, attrs = {})
        parse(RestClient.delete("#{Paperlex.base_url}/#{url}?#{attrs.merge(:token => Paperlex.token).to_query}"))
      end
    end

    def initialize(uuid, attrs = {})
      super(uuid.is_a?(Hash) ? uuid.merge(attrs) : attrs.merge(:uuid => uuid))
    end

    def to_uuid(object)
      object.respond_to?(:uuid) ? object.uuid : object
    end
  end
end
