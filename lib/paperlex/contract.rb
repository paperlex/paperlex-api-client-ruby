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
        attrs.symbolize_keys!
        signers = attrs.delete(:signers)
        result = new(JSON.parse(RestClient.post("#{Paperlex.base_url}/contracts.json", contract: attrs, token: Paperlex.token)))
        if signers.present?
          signers.each do |email|
            result.create_signer(email)
          end
        end
        result
      end
    end

    def create_signer(email)
      # TODO: we should make all signers instantiated as Paperlex::Signer objects, not just those added this way
      self.signers << Paperlex::Signer.create(contract_uuid: uuid, email: email)
    end

    def create_review_session(email, options = {})
      Paperlex::ReviewSession.create(options.merge(contract_uuid: uuid, email: email))
    end
  end
end
