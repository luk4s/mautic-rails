$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'mautic/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'mautic'
  s.version     = Mautic::VERSION
  s.authors     = ['Lukáš Pokorný']
  s.email       = ['pokorny@luk4s.cz']
  s.homepage    = 'https://github.com/luk4s/mautic-rails'
  s.summary     = 'Ruby on Rails Mautic integration'
  s.description = 'Rails client for Mautic API. Provide wrapper for push to mautic form'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.1'

  s.metadata['allowed_push_host'] = 'https://rubygems.org'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/*']

  s.add_dependency 'rails', '>= 6.0.0', '< 7.0'
  # s.add_dependency 'oauth', '~> 0.5.3'
  s.add_dependency 'oauth2', '~> 1.4'
  s.add_dependency 'rest-client', '~> 2.1'
end
