module Paperlex
  class Contract < Base
    # Provided by index
    property :created_at
    property :updated_at
    property :subject

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

    UPDATE_FIELDS = [:subject, :number_of_signers, :responses, :signature_callback_url, :body]
    CREATE_FIELDS = [*UPDATE_FIELDS, :slaw_id]

    class << self
      def all
        get('contracts.json').map {|attrs| new(attrs) }
      end

      def create(attrs = {})
        attrs.symbolize_keys!
        signers = attrs.delete(:signers)
        attrs.assert_valid_keys(CREATE_FIELDS)
        result = new(post("contracts.json", contract: attrs, token: Paperlex.token))
        if signers.present?
          signers.each do |email|
            result.create_signer(email: email)
          end
        end
        result
      end

      def url_for(uuid)
        "contracts/#{uuid}.json"
      end

      def find(uuid)
        new(get(url_for(uuid)))
      end
    end

    def html_url
      "#{Paperlex.base_url}/contracts/#{uuid}.html?#{{token: Paperlex.token}.to_query}"
    end

    def save!(fields = nil)
      fields ||= UPDATE_FIELDS
      self.class.put(self.class.url_for(uuid), Hash[fields.map {|field| [field, self[field]]}])
      self
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
