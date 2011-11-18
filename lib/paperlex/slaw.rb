module Paperlex
  class Slaw < Base
    include RootObject

    property :public
    property :name
    property :description
    property :body

    class << self
      def url_name
        "slaws"
      end

      def update_fields
        [:name, :body, :description]
      end
      alias :create_fields :update_fields

      def create(attrs = {})
        attrs.symbolize_keys!
        attrs.assert_valid_keys(create_fields)
        attrs = post(collection_url, :slaw => attrs)
        new(attrs)
      end
    end

    def html_url(responses)
      params = {:token => Paperlex.token}
      params[:responses] = responses if responses.present?
      "#{Paperlex.base_url}/slaws/#{uuid}.html?#{params.to_query}"
    end

    def destroy
      self.class.delete(self.class.url_for(uuid))
    end
  end
end
