$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "swell_id/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "swell_id"
  s.version     = SwellId::VERSION
  s.authors     = ["Gk Parish-Philp", "Michael Ferguson"]
  s.email       = ["gk@gkparishphilp.com"]
  s.homepage    = "http://gkparishphilp.com"
  s.summary     = "Basic User/Auth for rails."
  s.description = "Basic User/Auth for rails."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.1"

  s.add_dependency "acts-as-taggable-array-on"
  s.add_dependency "devise"
  s.add_dependency "friendly_id", '~> 5.1.0'


  s.add_development_dependency "sqlite3"
end
