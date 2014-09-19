$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'jackal-commander/version'
Gem::Specification.new do |s|
  s.name = 'jackal-commander'
  s.version = Jackal::Commander::VERSION.version
  s.summary = 'Message processing helper'
  s.author = 'Chris Roberts'
  s.email = 'code@chrisroberts.org'
  s.homepage = 'https://github.com/carnivore-rb/jackal-commander'
  s.description = 'Command helpers'
  s.require_path = 'lib'
  s.license = 'Apache 2.0'
  s.add_dependency 'jackal'
  s.add_dependency 'childprocess'
  s.files = Dir['lib/**/*'] + %w(jackal-commander.gemspec README.md CHANGELOG.md CONTRIBUTING.md LICENSE)
end
