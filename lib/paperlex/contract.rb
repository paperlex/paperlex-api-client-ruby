module Paperlex
  class Contract < Base
    include RootObject

    extend ActiveSupport::Autoload
    autoload :Signers

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

    class << self
      def update_fields
        [:subject, :number_of_signers, :responses, :signature_callback_url, :body]
      end

      def create_fields
        [*update_fields, :slaw_id]
      end

      def url_name
        "contracts"
      end

      def create(attrs = {})
        attrs.symbolize_keys!
        signers = attrs.delete(:signers)
        attrs.assert_valid_keys(create_fields)
        result = new(post("contracts.json", :contract => attrs))
        if signers.present?
          signers.each do |email|
            result.create_signer(:email => email)
          end
        end
        result
      end
    end

    def html_url
      "#{Paperlex.base_url}/contracts/#{uuid}.html?#{{:token => Paperlex.token}.to_query}"
    end

    # Signers
    def create_signer(attrs = {})
      self.signers << Paperlex::Contract::Signers[uuid].create(attrs)
    end

    def fetch_signers
      self.signers = Paperlex::Contract::Signers[uuid].all
    end

    def fetch_signer(signer_uuid)
      signers.delete_if {|signer| signer['uuid'] == signer_uuid }
      self.signers << Paperlex::Contract::Signers[uuid].find(signer_uuid)
    end

    def update_signer(signer_uuid, attrs)
      Paperlex::Contract::Signers[uuid].update(signer_uuid, attrs)
    end

    def delete_signer(signer_uuid)
      Paperlex::Contract::Signers[uuid].destroy(signer_uuid)
    end

    # Review Sessions
    def create_review_session(attrs = {})
      Paperlex::ReviewSession.create(attrs.merge(:contract_uuid => uuid))
    end

    # Versions
    def versions
      Paperlex::Contract::Versions[uuid].all
    end

    def at_version(version_index)
      new(Paperlex::Contract::Versions[uuid].fetch(version_index))
    end

    def revert_to_version(version_index)
      new(Paperlex::Contract::Versions[uuid].revert_to(version_index))
    end

    # Responses
    def update_responses
      self.responses = Paperlex::Responses[uuid].all
    end

    def update_response(key)
      self.responses[key] = Paperlex::Responses[uuid].fetch(key)
    end

    def save_responses
      Paperlex::Responses[uuid].update_all(responses)
    end

    def save_response(key)
      Paperlex::Responses[uuid].update(key, responses[key])
    end

    def delete_response(key)
      Paperlex::Responses[uuid].destroy(key)
      self.responses.delete(key)
    end
  end
end
