module Paperlex
  class Contract < Base
    class Responses < Base
      attr_reader :contract_uuid

      def initialize(contract_uuid)
        @contract_uuid = contract_uuid
      end

      def all
        self.class.get(collection_url)
      end

      def update_all(responses)
        self.class.post(collection_url, {:responses => responses})
      end

      def find(key)
        self.class.get(url_for(key)).first
      end

      def update(key, value)
        self.class.put(url_for(key), {:value => value})
      end

      def destroy(key)
        self.class.delete(url_for(key))
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
