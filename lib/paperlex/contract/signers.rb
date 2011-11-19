module Paperlex
  class Contract < Base
    class Signers < Paperlex::Base
      attr_reader :contract_uuid

      CREATE_FIELDS = [:email]

      class << self
        def [](contract_uuid)
          new(contract_uuid)
        end
      end

      def initialize(contract_uuid)
        @contract_uuid = contract_uuid
      end

      def create(attrs = {})
        attrs.symbolize_keys!
        attrs.assert_valid_keys(CREATE_FIELDS)
        Paperlex::Signer.new(self.class.post(collection_url, :signer => attrs).merge(:contract_uuid => contract_uuid))
      end

      def all
        self.class.get(collection_url)
      end

      def find(uuid)
        self.class.get(url_for(uuid))
      end

      def update(uuid, attrs)
        self.class.put(url_for(uuid), :signer => attrs)
      end

      def destroy(uuid)
        self.class.delete(url_for(uuid))
      end

      private

      def collection_url
        "contracts/#{contract_uuid}/signers.json"
      end

      def url_for(uuid)
        "contracts/#{contract_uuid}/signers/#{uuid}.json"
      end
    end
  end
end
