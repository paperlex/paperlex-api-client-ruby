module Paperlex
  class Versions < Base
    include SubObject

    attr_reader :uuid

    def initialize(uuid)
      @uuid = uuid
    end

    def revert_to(version_index)
      post("#{base}/#{uuid}/versions/#{version_index}/revert.json")
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
