lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vns/version'

Gem::Specification.new do |s|
  s.name        = 'vns'
  s.version     = VNS::VERSION
  s.date        = '2021-01-23'
  s.summary     = 'VNS'
  s.description = 'A gem to execute Variable Neighborhood Search algorithm in optimization problems'
  s.authors     = ['Manuel Bustillo']
  s.email       = 'mayn13@gmail.com'
  s.files       = ['lib/vns.rb']
  s.homepage    = 'https://rubygems.org/exploradoresdemadrid/vns'
  s.license = 'MIT'

  s.add_runtime_dependency 'activesupport'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
end
