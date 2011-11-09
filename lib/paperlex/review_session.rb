module Paperlex
  class ReviewSession < Hashie::Dash
    property :expires_at, :required => true
    property :uuid, :required => true
    property :token, :required => true
    property :url, :required => true
    property :email, :required => true
    property :contract_uuid, :required => true

    class << self
      def create(attrs = {})
        attrs.symbolize_keys!
        contract_uuid = attrs.delete(:contract_uuid)
        new(JSON.parse(RestClient.post("#{Paperlex.base_url}/contracts/#{contract_uuid}/review_sessions.json", :review_session => attrs, :token => Paperlex.token)).merge(:contract_uuid => contract_uuid))
      end
    end
  end
end
