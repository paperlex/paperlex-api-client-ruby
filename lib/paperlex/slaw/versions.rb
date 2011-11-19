module Paperlex
  class Slaw < Base
    class Versions < Base
      class << self
        def [](slaw_uuid)
          new(slaw_uuid)
        end
      end

      attr_reader :slaw_uuid

      def initialize(slaw_uuid)
        @slaw_uuid = slaw_uuid
      end

      def all
        get(collection_url)
      end

      def fetch(version_index)
        get(url_for(version_index))
      end

      def revert_to(version_index)
        post("slaws/#{slaw_uuid}/versions/#{version_index}/revert.json")
      end

      private

      def collection_url
        "slaws/#{slaw_uuid}/versions.json"
      end

      def url_for(version_index)
        "slaws/#{slaw_uuid}/versions/#{version_index}.json"
      end
    end
  end
end
