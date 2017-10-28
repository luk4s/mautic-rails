$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'mautic/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'mautic'
  s.version     = Mautic::VERSION
  s.authors     = ['Lukáš Pokorný']
  s.email       = ['pokorny@luk4s.cz']
  s.homepage    = 'https://luk4s.cz'
  s.summary     = 'Ruby Mautic integration'
  s.description = 'Ruby client for Mautic API. Provide wrapper for push to mautic form'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.1.4'
  # s.add_dependency 'oauth', '~> 0.5.3'
  s.add_dependency 'oauth2', '~> 1.4.0'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency('rspec-rails', '~> 3.6')
  s.add_development_dependency('factory_bot_rails', '~> 4.8.2')
  # s.add_development_dependency('capybara', '~> 2')
  # s.add_development_dependency('selenium-webdriver')
  s.add_development_dependency('database_cleaner')
  s.add_development_dependency('faker', '~> 1.8.4')
  s.add_development_dependency('webmock', '~> 3.1.0')
  s.add_development_dependency('pry-rails', '~> 0.3.6')
end
