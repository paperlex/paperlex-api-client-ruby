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

      [:get, :post, :put, :delete].each do |method|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{method}(url, attrs = {})
            parse(RestClient::Request.execute(:method => :#{method}, :url => "\#{Paperlex.base_url}/\#{url}", :payload => attrs.merge(:token => Paperlex.token)))
          end
        METHOD
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
