module Paperlex
  class Slaw < Hashie::Mash
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
      "#{Paperlex.base_url}/slaws/#{@uuid}.html?#{{responses: responses || {}, token: Paperlex.token}.to_query}"
    end

    def to_html(responses)
      RestClient.get(html_url(responses))
    end
  end
end
