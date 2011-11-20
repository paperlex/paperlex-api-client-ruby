module Paperlex
  class Contract < Base
    class Responses
      include SubObject

      attr_reader :contract_uuid

      def initialize(contract_uuid)
        @contract_uuid = contract_uuid
      end

      def update_all(responses)
        post(collection_url, {:responses => responses})
      end

      def find(key)
        super.first
      end

      def update(key, value)
        put(url_for(key), {:value => value})
      end

      def destroy(key)
        delete(url_for(key))
      end

      private

      def collection_url
        "contracts/#{contract_uuid}/responses.json"
      end

      def url_for(key)
        "contracts/#{contract_uuid}/responses/#{key}.json"
      end
    end
  end
end
