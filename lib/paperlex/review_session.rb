module Paperlex
  class ReviewSession < Base
    property :expires_at, :required => true
    property :token, :required => true
    property :url, :required => true
    property :email, :required => true
    property :contract_uuid, :required => true

    CREATE_FIELDS = [:email, :expires_at, :expires_in]

    class << self
      def create(attrs = {})
        attrs.symbolize_keys!
        contract_uuid = attrs.delete(:contract_uuid)
        attrs.assert_valid_keys(CREATE_FIELDS)
        new(post("contracts/#{contract_uuid}/review_sessions.json", :review_session => attrs, :token => Paperlex.token).merge(:contract_uuid => contract_uuid))
      end
    end
  end
end
