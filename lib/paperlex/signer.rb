module Paperlex
  class Signer < Base
    property :contract_uuid, :required => true
    property :email, :required => true
  end
end
