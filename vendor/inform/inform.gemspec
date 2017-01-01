$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "inform/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "inform"
  s.version     = Inform::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = "Summary of Inform."
  s.description = "Description of Inform."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.5.2"
  s.add_development_dependency "bootstrap-sass", "~> 3.3.7"
  s.add_development_dependency "pg"
  s.add_development_dependency "jquery-rails"
  s.add_development_dependency "sass-rails","~> 5.0"


end
