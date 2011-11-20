module Paperlex
  class Contract < Base
    class Signers < Paperlex::Base
      include SubObject

      attr_reader :contract_uuid

      class << self
        def create_fields
          [:email]
        end
      end

      def initialize(contract_uuid)
        @contract_uuid = contract_uuid
      end

      def create(attrs = {})
        attrs.symbolize_keys!
        attrs.assert_valid_keys(self.class.create_fields)
        Paperlex::Signer.new(self.class.post(collection_url, :signer => attrs).merge(:contract_uuid => contract_uuid))
      end

      def new_object(attrs)
        Paperlex::Signer.new(attrs.merge(:contract_uuid => contract_uuid))
      end

      def update(uuid, attrs)
        new_object(self.class.put(url_for(uuid), :signer => attrs))
      end

      def destroy(uuid)
        self.class.delete(url_for(uuid))
      end

      private

      def collection_url
        "contracts/#{contract_uuid}/signers.json"
      end

      def url_for(uuid)
        "contracts/#{contract_uuid}/signers/#{to_uuid(uuid)}.json"
      end
    end
  end
end
