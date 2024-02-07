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

  s.required_ruby_version = '>= 2.5'

  s.metadata['allowed_push_host'] = 'https://rubygems.org'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/*']

  s.add_dependency 'rails', '>= 6.0.0'
  # s.add_dependency 'oauth', '~> 0.5.3'
  s.add_dependency 'oauth2', '~> 1.4.9'
  s.add_dependency 'ostruct', '>= 0.5.3'
  s.add_dependency 'rest-client', '~> 2.1'

  s.add_development_dependency 'database_cleaner', '~> 2.0'
  s.add_development_dependency 'factory_bot_rails', '~> 6.4'
  s.add_development_dependency 'faker', '~> 3.2'
  s.add_development_dependency 'pry-rails', '~> 0.3'
  s.add_development_dependency 'rspec-rails', '~> 6.1'
  s.add_development_dependency 'sqlite3', '~> 1.7'
  s.add_development_dependency 'webmock', '~> 3.20'
end
