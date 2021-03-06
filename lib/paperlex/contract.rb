module Paperlex
  class Contract < Base
    include RootObject

    extend ActiveSupport::Autoload
    autoload :Signers
    autoload :Signatures
    autoload :Responses
    autoload :ReviewSessions
    autoload :Versions

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
    property :review_sessions

    class << self
      def update_fields
        [:subject, :number_of_signers, :responses, :signature_callback_url, :body]
      end

      def create_fields
        [*update_fields] << :slaw_id
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

    def to_html
      RestClient.get(html_url)
    end

    # Signers
    def signers=(signers)
      self[:signers] = signers.map {|signer| signer.is_a?(Paperlex::Signer) ? signer : Paperlex::Signer.new(signer.merge(:contract_uuid => uuid)) }
    end

    def create_signer(attrs = {})
      signer = Signers[uuid].create(attrs)
      self.signers << signer
      signer
    end

    def fetch_signers
      self.signers = Signers[uuid].all
      signers
    end

    def fetch_signer(signer)
      remove_signer!(signer)
      new_signer = Signers[uuid].find(signer)
      self.signers << new_signer
      new_signer
    end

    def update_signer(signer, attrs)
      remove_signer!(signer)
      updated_signer = Signers[uuid].update(signer, attrs)
      self.signers << updated_signer
      updated_signer
    end

    def delete_signer(signer)
      remove_signer!(signer)
      Signers[uuid].destroy(signer)
    end

    # Review Sessions
    def review_sessions=(review_sessions)
      self[:review_sessions] = review_sessions.map {|session| session.is_a?(Paperlex::ReviewSession) ? session : Paperlex::ReviewSession.new(session.merge(:contract_uuid => uuid)) }
    end

    def review_sessions
      self[:review_sessions] ||= []
    end

    def create_review_session(attrs = {})
      session = ReviewSessions[uuid].create(attrs)
      self.review_sessions << session
      session
    end

    def fetch_review_sessions
      self.review_sessions = ReviewSessions[uuid].all
      review_sessions
    end

    def fetch_review_session(review_session_uuid)
      remove_review_session!(review_session_uuid)
      new_session = ReviewSessions[uuid].find(review_session_uuid)
      self.review_sessions << new_session
      new_session
    end

    def update_review_session(review_session_uuid, attrs)
      remove_review_session!(review_session_uuid)
      updated_session = ReviewSessions[uuid].update(review_session_uuid, attrs)
      self.review_sessions << updated_session
      updated_session
    end

    def delete_review_session(review_session_uuid)
      remove_review_session!(review_session_uuid)
      ReviewSessions[uuid].destroy(review_session_uuid)
    end

    # Signatures
    # Requires access to the remote signature program:
    # https://api.paperlex.com/remote_signature.html
    def signatures=(signatures)
      self[:signatures] = signatures.map {|signature| signature.is_a?(Paperlex::Signature) ? signature : Paperlex::Signature.new(signature.merge(:contract_uuid => uuid)) }
    end

    def fetch_signatures
      self.signatures = Signatures[uuid].all
      signatures
    end

    def fetch_signature(signature_uuid)
      remove_signature!(signature_uuid)
      new_signature = Signatures[uuid].find(signature_uuid)
      self.signatures << new_signature
      new_signature
    end

    def create_signature(attrs)
      signature = Signatures[uuid].create(attrs)
      self.signatures << signature
      signature
    end

    # Versions
    def versions
      Versions[uuid].all.map {|version| Version.new(version) }
    end

    def at_version(version_index)
      self.class.new(Versions[uuid].find(version_index))
    end
    alias_method :version_at, :at_version

    def revert_to_version(version_index)
      self.class.new(Versions[uuid].revert_to(version_index))
    end

    # Responses
    def responses
      self[:responses] ||= {}
    end

    def fetch_responses
      self.responses = Responses[uuid].all
    end

    def fetch_response(key)
      self.responses[key] = Responses[uuid].find(key)
    end

    def save_responses
      Responses[uuid].update_all(responses)
    end

    def save_response(key)
      Responses[uuid].update(key, responses[key])
    end

    def delete_response(key)
      Responses[uuid].destroy(key)
      self.responses.delete(key)
      responses
    end

    private

    def short_name
      :contract
    end

    def remove_signer!(signer_to_remove)
      signer_uuid = to_uuid(signer_to_remove)
      signers.delete_if {|signer| signer['uuid'] == signer_uuid }
    end

    def remove_signature!(signature_to_remove)
      signature_uuid = to_uuid(signature_to_remove)
      signatures.delete_if {|signature| signature['uuid'] == signature_uuid }
    end

    def remove_review_session!(review_session_to_remove)
      review_session_uuid = to_uuid(review_session_to_remove)
      review_sessions.delete_if {|review_session| review_session['uuid'] == review_session_uuid }
    end
  end
end
