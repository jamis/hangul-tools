lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hangul_tools/version"

Gem::Specification.new do |gem|
  gem.version     = HangulTools::Version::STRING
  gem.name        = "hangul_tools"
  gem.authors     = ["Jamis Buck"]
  gem.email       = ["jamis@jamisbuck.org"]
  gem.homepage    = "http://github.com/jamis/hangul-tools"
  gem.summary     = "Romanize Korean text"
  gem.description = "Convert Korean text to latin characters, using either the Revised system or McCune-Reischauer."
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^test/})
  gem.require_paths = ["lib"]

  ##
  # Development dependencies
  #
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit"
  gem.add_development_dependency "rubygems-tasks", "~> 0"
end
