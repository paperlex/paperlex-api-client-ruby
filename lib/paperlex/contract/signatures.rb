module Paperlex
  class Contract < Base
    class Signatures < Paperlex::Base
      include SubObject

      class << self
        def create_fields
          [:signer, :identity, :remote_ip, :user_agent]
        end
      end

      def object_class
        Paperlex::Signature
      end

      def short_name
        :signature
      end

      private

      def collection_url
        "contracts/#{contract_uuid}/signatures.json"
      end

      def url_for(uuid)
        "contracts/#{contract_uuid}/signatures/#{to_uuid(uuid)}.json"
      end
    end
  end
end
