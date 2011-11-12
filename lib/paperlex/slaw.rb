module Paperlex
  class Slaw < Base
    property :public
    property :name
    property :description
    property :body

    CREATE_FIELDS = [:name, :body, :description]

    class << self
      def all
        get('slaws.json').map {|attrs| new(attrs) }
      end

      def create(attrs = {})
        attrs.symbolize_keys!
        attrs.assert_valid_keys(CREATE_FIELDS)
        attrs = post("slaws.json", slaw: attrs, token: Paperlex.token)
        new(attrs)
      end

      def find(uuid)
        new(uuid)
      end
    end

    def html_url(responses)
      params = {token: Paperlex.token}
      params[:responses] = responses if responses.present?
      "#{Paperlex.base_url}/slaws/#{uuid}.html?#{params.to_query}"
    end

    def to_html(responses)
      RestClient.get(html_url(responses))
    end
  end
end
