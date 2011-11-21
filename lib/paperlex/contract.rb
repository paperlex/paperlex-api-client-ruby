module Paperlex
  class Contract < Base
    include RootObject

    extend ActiveSupport::Autoload
    autoload :Signers
    autoload :Responses
    autoload :ReviewSessions

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

    # Versions
    def versions
      Versions[uuid].all
    end

    def at_version(version_index)
      new(Versions[uuid].find(version_index))
    end

    def revert_to_version(version_index)
      new(Versions[uuid].revert_to(version_index))
    end

    # Responses
    def update_responses
      self.responses = Responses[uuid].all
    end

    def update_response(key)
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
    end

    private

    def remove_signer!(signer_to_remove)
      signer_uuid = to_uuid(signer_to_remove)
      signers.delete_if {|signer| signer['uuid'] == signer_uuid }
    end

    def remove_review_session!(review_session_to_remove)
      review_session_uuid = to_uuid(review_session_to_remove)
      review_sessions.delete_if {|review_session| review_session['uuid'] == review_session_uuid }
    end
  end
end
