module Paperlex
  class Signer < Hashie::Dash
    property :uuid, :required => true
    property :contract_uuid, :required => true
    property :email, :required => true

    CREATE_PARAMS = [:email]

    class << self
      def create(attrs = {})
        attrs.symbolize_keys!
        contract_uuid = attrs.delete(:contract_uuid)
        attrs.assert_valid_keys(CREATE_PARAMS)
        new(JSON.parse(RestClient.post("#{Paperlex.base_url}/contracts/#{contract_uuid}/signers.json", signer: attrs, token: Paperlex.token)).merge(:contract_uuid => contract_uuid))
      end
    end
  end
end
