$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "paperlex/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "paperlex"
  s.version     = Paperlex::VERSION
  s.authors     = ["Paperlex"]
  s.email       = ["api-help@paperlex.com"]
  s.homepage    = "https://api.paperlex.com/"
  s.summary     = "A Paperlex API client in Ruby"
  s.description = "Dead-simple Legal Documents"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rest-client"
  s.add_dependency "hashie"
  s.add_dependency "json"
  s.add_dependency "configatron"
  s.add_dependency "activesupport", ">= 3.0.0"

  s.add_development_dependency "rspec"
  s.add_development_dependency "faker"
  s.add_development_dependency "fakeweb"
end
