module Paperlex
  class Contract < Base
    class Versions < Base
      class << self
        def [](contract_uuid)
          new(contract_uuid)
        end
      end

      attr_reader :contract_uuid

      def initialize(contract_uuid)
        @contract_uuid = contract_uuid
      end

      def all
        get(collection_url)
      end

      def fetch(version_index)
        get(url_for(version_index))
      end

      def revert_to(version_index)
        post("contracts/#{contract_uuid}/versions/#{version_index}/revert.json")
      end

      private

      def collection_url
        "contracts/#{contract_uuid}/versions.json"
      end

      def url_for(version_index)
        "contracts/#{contract_uuid}/versions/#{version_index}.json"
      end
    end
  end
end
