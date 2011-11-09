module Paperlex
  class Slaw < Hashie::Dash
    property :uuid, :required => true
    property :public, :required => true
    property :name, :required => true
    property :description, :required => true
    property :body, :required => true
    property :current_version, :required => true
    property :created_at, :required => true
    property :updated_at, :required => true

    class << self
      def create(attrs = {})
        attrs = JSON.parse(RestClient.post("#{Paperlex.base_url}/slaws.json", slaw: attrs, token: Paperlex.token))
        new(attrs['uuid'], attrs)
      end

      def find(uuid)
        new(uuid)
      end
    end

    def initialize(uuid, attrs = {})
      @uuid = uuid
      super(attrs)
    end

    def html_url(responses)
      params = {token: Paperlex.token}
      params[:responses] = responses if responses.present?
      "#{Paperlex.base_url}/slaws/#{@uuid}.html?#{params.to_query}"
    end

    def to_html(responses)
      RestClient.get(html_url(responses))
    end
  end
end
