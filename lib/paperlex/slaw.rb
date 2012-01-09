module Paperlex
  class Slaw < Base
    include RootObject

    extend ActiveSupport::Autoload
    autoload :Versions

    property :public
    property :name
    property :description
    property :body
    property :response_keys

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

    def html_url(responses = nil, options = {})
      params = options.merge(:token => Paperlex.token)
      params[:responses] = responses if responses.present?
      "#{Paperlex.base_url}/slaws/#{uuid}.html?#{params.to_query}"
    end

    def to_html(responses = nil, options = {})
      RestClient.get(html_url(responses, options))
    end

    def destroy
      self.class.delete(self.class.url_for(uuid))
    end

    # Versions
    def versions
      Paperlex::Slaw::Versions[uuid].all.map {|version| Version.new(version) }
    end

    def at_version(version_index)
      self.class.new(Paperlex::Slaw::Versions[uuid].find(version_index))
    end
    alias_method :version_at, :at_version

    def revert_to_version(version_index)
      self.class.new(Paperlex::Slaw::Versions[uuid].revert_to(version_index))
    end

    private

    def short_name
      :slaw
    end
  end
end
