require 'active_support/dependencies/autoload'
require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/to_query'
require 'hashie/dash'
require 'rest-client'
require 'json'
require 'configatron'

module Paperlex
  extend ActiveSupport::Autoload

  autoload_under 'base' do
    autoload :Base
    autoload :RootObject
    autoload :SubObject
  end
  autoload :Contract
  autoload :Slaw
  autoload :ReviewSession
  autoload :Responses
  autoload :Signer

  SANDBOX_URL = 'https://sandbox.api.paperlex.com/v1'
  LIVE_URL = 'https://api.paperlex.com/v1'

  class << self
    delegate :configure_from_hash, :base_url, :token, :base_url=, :token=, :to => :configatron

    def live!
      self.base_url = LIVE_URL
    end
  end

  configatron.set_default(:base_url, SANDBOX_URL)
  configatron.set_default(:token, nil)
end
