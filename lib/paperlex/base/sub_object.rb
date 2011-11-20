module Paperlex
  module SubObject
    extend ActiveSupport::Concern

    module ClassMethods
      def [](parent_uuid)
        new(parent_uuid)
      end
    end

    def all
      self.class.get(collection_url)
    end

    def find(uuid)
      new_object(self.class.get(url_for(uuid)))
    end
  end
end
