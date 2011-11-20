module Paperlex
  class ReviewSession < Base
    property :expires_at, :required => true
    property :token, :required => true
    property :url, :required => true
    property :email, :required => true
    property :contract_uuid, :required => true
  end
end
