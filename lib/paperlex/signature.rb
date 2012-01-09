module Paperlex
  class Signature < Base
    property :contract_uuid, :required => true
    property :signer_uuid, :required => true
    property :identity_verification_method, :required => true
    property :identity_verification_value, :required => true
    property :created_at, :required => true
  end
end
