$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "paperlex/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "paperlex_api_client"
  s.version     = Paperlex::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of PaperlexApiClient."
  s.description = "TODO: Description of PaperlexApiClient."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rest-client"
  s.add_dependency "hashie"
  s.add_dependency "json"
  s.add_dependency "active_support", ">= 3.0.0"

  s.add_development_dependency "rspec"
  s.add_development_dependency "faker"
  s.add_development_dependency "fakeweb"
end
