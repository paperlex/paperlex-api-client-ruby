module Paperlex
  class Contract < Base
    class ReviewSessions < Paperlex::Base
      include SubObject

      class << self
        def create_fields
          [:email, :expires_at, :expires_in]
        end
      end

      def object_class
        Paperlex::ReviewSession
      end

      def short_name
        :review_session
      end

      private

      def collection_url
        "contracts/#{contract_uuid}/review_sessions.json"
      end

      def url_for(uuid)
        "contracts/#{contract_uuid}/review_sessions/#{uuid}.json"
      end
    end
  end
end
