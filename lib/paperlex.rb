require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/keys'
require 'hashie/dash'
require 'rest-client'
require 'json'
require 'configatron'

module Paperlex
  extend ActiveSupport::Autoload

  autoload :Contract
  autoload :Slaw
  autoload :Signer
  autoload :ReviewSession

  class << self
    delegate :configure_from_hash, :base_url, :token, :base_url=, :token=, :to => :configatron
  end

  default_url =
    if ENV['RACK_ENV'] == 'production' || ENV['RAILS_ENV'] == 'production'
      'https://api.paperlex.com/v1'
    else
      'https://sandbox.api.paperlex.com/v1'
    end
  configatron.set_default(:base_url, default_url)
  configatron.set_default(:token, nil)
end
