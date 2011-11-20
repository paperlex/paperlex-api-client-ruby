module Paperlex
  class Contract < Base
    class Signers < Paperlex::Base
      include SubObject

      class << self
        def create_fields
          [:email]
        end
      end

      def object_class
        Paperlex::Signer
      end

      def short_name
        :signer
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
