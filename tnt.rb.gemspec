lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tnt/version'

Gem::Specification.new do |spec|
  spec.name          = 'tnt.rb'
  spec.version       = TNT::VERSION
  spec.authors       = ['Stas SUȘCOV']
  spec.email         = ['stas@nerd.ro']

  spec.summary       = 'TNT (Express Web Services) Ruby SDK'
  spec.description   = 'Ruby SDK for working with TNT shipping web services.'
  spec.homepage      = 'https://github.com/luneteyewear/tnt.rb'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'gyoku'
  spec.add_dependency 'http-rest_client'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'ffaker'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yardstick'
end
