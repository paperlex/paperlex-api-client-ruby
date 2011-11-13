module Paperlex
  module RootObject
    extend ActiveSupport::Concern

    module ClassMethods
      def collection_url
        "#{url_name}.json"
      end

      def url_for(uuid)
        "#{url_name}/#{uuid}.json"
      end

      def all
        get(collection_url).map {|attrs| new(attrs) }
      end

      def find(uuid)
        new(get(url_for(uuid)))
      end
    end

    def to_html
      RestClient.get(html_url(responses))
    end

    def save!(fields = nil)
      fields ||= self.class.update_fields
      self.class.put(self.class.url_for(uuid), Hash[fields.map {|field| [field, self[field]]}])
      self
    end
  end
end
