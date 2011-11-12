module Paperlex
  class Contract < Base
    # Provided by index
    property :created_at, :required => true
    property :updated_at, :required => true
    property :subject, :required => true

    # Provided by show
    property :body
    property :current_version
    property :locked
    property :number_of_signers
    property :number_of_identity_verifications
    property :responses
    property :signers
    property :signatures
    property :signature_callback_url

    CREATE_PARAMS = [:subject, :number_of_signers, :responses, :signature_callback_url, :body, :slaw_id]

    class << self
      def all
        get('contracts.json').map {|attrs| new(attrs) }
      end

      def create(attrs = {})
        attrs.symbolize_keys!
        signers = attrs.delete(:signers)
        attrs.assert_valid_keys(CREATE_PARAMS)
        result = new(post("contracts.json", contract: attrs, token: Paperlex.token))
        if signers.present?
          signers.each do |email|
            result.create_signer(email: email)
          end
        end
        result
      end

      def find(uuid)
        new(get("contracts/#{uuid}.json"))
      end
    end

    def create_signer(attrs = {})
      # TODO: we should make all signers instantiated as Paperlex::Signer objects, not just those added this way
      self.signers << Paperlex::Signer.create(attrs.merge(contract_uuid: uuid))
    end

    def create_review_session(attrs = {})
      Paperlex::ReviewSession.create(attrs.merge(contract_uuid: uuid))
    end
  end
end
