require 'bundler'
require 'active_support/core_ext/object/blank'
require 'securerandom'

Bundler.require(:default, :development)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f }

if ENV['TOKEN']
  Paperlex.token = ENV['TOKEN']
elsif ENV['REMOTE_SIGNATURE_TOKEN']
  # we'll set Paperlex.token where needed in the specs
else
  FakeWeb.allow_net_connect = false
end

if ENV['PAPERLEX_URL']
  Paperlex.base_url = ENV['PAPERLEX_URL']
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
end
