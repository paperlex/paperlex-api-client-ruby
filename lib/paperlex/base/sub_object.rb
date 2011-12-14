module Paperlex
  module SubObject
    extend ActiveSupport::Concern

    included do
      attr_reader :contract_uuid
    end

    def initialize(contract_uuid)
      @contract_uuid = contract_uuid
    end

    def new_object(attrs)
      object_class.new(attrs.merge(:contract_uuid => contract_uuid))
    end

    def all
      self.class.get(collection_url)
    end

    def create(attrs = {})
      attrs.symbolize_keys!
      attrs.assert_valid_keys(self.class.create_fields)
      new_object(self.class.post(collection_url, short_name => attrs))
    end

    def find(uuid)
      new_object(self.class.get(url_for(uuid)))
    end

    def update(uuid, attrs)
      new_object(self.class.put(url_for(uuid), short_name => attrs))
    end

    def destroy(uuid)
      self.class.delete(url_for(uuid))
    end
  end
end
