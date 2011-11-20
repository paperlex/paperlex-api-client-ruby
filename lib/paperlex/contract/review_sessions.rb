module Paperlex
  class Contract < Base
    class ReviewSessions < Paperlex::Base
      include SubObject

      attr_reader :contract_uuid

      class << self
        def create_fields
          [:email, :expires_at, :expires_in]
        end
      end

      def initialize(contract_uuid)
        @contract_uuid = contract_uuid
      end

      def create(attrs = {})
        attrs.symbolize_keys!
        attrs.assert_valid_keys(self.class.create_fields)
        self.class.post(collection_url, :signer => attrs).merge(:contract_uuid => contract_uuid)
      end

      def update(uuid, attrs)
        self.class.put(url_for(uuid), :signer => attrs)
      end

      def destroy(uuid)
        self.class.delete(url_for(uuid))
      end

      private

      def collection_url
        "contracts/#{contract_uuid}/review_sessions.json"
      end

      def url_for(uuid)
        "contracts/#{contract_uuid}/review_sessions/#{uuid}.json"
      end
    end
  end
end
