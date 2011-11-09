module Paperlex
  class Contract < Hashie::Dash
    property :uuid, :required => true
    property :subject, :required => true
    property :body, :required => true
    property :current_version, :required => true
    property :locked, :required => true
    property :number_of_signers, :required => true
    property :number_of_identity_verifications, :required => true
    property :responses
    property :signers, :required => true
    property :signatures, :required => true
    property :signature_callback_url
    property :created_at, :required => true
    property :updated_at, :required => true

    class << self
      def create(attrs = {})
        new(JSON.parse(RestClient.post("#{Paperlex.base_url}/contracts.json", contract: attrs, token: Paperlex.token)))
      end
    end
  end
end
