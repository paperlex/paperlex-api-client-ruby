module Paperlex
  class Versions < Base
    class << self
      def [](uuid)
        new(uuid)
      end
    end

    attr_reader :uuid

    def initialize(uuid)
      @uuid = uuid
    end

    def all
      self.class.get(collection_url)
    end

    def find(version_index)
      self.class.get(url_for(version_index))
    end

    def revert_to(version_index)
      self.class.post("#{base}/#{uuid}/versions/#{version_index}/revert.json")
    end

    private

    def collection_url
      "#{base}/#{uuid}/versions.json"
    end

    def url_for(version_index)
      "#{base}/#{uuid}/versions/#{version_index}.json"
    end
  end
end
