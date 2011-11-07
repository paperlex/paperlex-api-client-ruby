module Paperlex
  class Contract < Hashie::Mash
    class << self
      def create(attrs = {})
        new(JSON.parse(RestClient.post("#{Paperlex.base_url}/contracts.json", contract: attrs, token: Paperlex.token)))
      end
    end
  end
end
