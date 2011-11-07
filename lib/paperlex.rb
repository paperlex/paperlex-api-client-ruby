require 'active_support/dependencies/autoload'
require 'hashie/mash'
require 'rest-client'
require 'json'

module Paperlex
  extend ActiveSupport::Autoload

  autoload :Contract
  autoload :Slaw

  class << self
    attr_accessor :base_url, :token
  end
end
