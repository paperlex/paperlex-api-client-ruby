module Paperlex
  class Responses
    attr_reader :contract_uuid

    class << self
      def [](contract_uuid)
        new(contract_uuid)
      end      
    end

    def initialize(contract_uuid)
      @contract_uuid = contract_uuid
    end

    def all
      get(collection_url)
    end

    def update_all(responses)
      post(collection_url, {:responses => responses})
    end

    def fetch(key)
      get(url_for(key)).first
    end

    def update(key, value)
      put(url_for(key), {:value => value})
    end

    def destroy(key)
      delete(url_for(key))
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
