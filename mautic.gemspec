$:.push File.expand_path('../lib', __FILE__)

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

  s.required_ruby_version = '>= 2.3'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/*']

  s.add_dependency 'rails', '>= 4.2.8'
  # s.add_dependency 'oauth', '~> 0.5.3'
  s.add_dependency 'oauth2', '~> 1.4'
  s.add_dependency 'rest-client', '~> 2.0'

  s.add_development_dependency 'sqlite3', '~> 1.4'
  s.add_development_dependency('rspec-rails', '~> 3.7')
  s.add_development_dependency('factory_bot_rails', '~> 4.8')
  s.add_development_dependency('database_cleaner', '~> 1.6')
  s.add_development_dependency('faker', '~> 1.8')
  s.add_development_dependency('webmock', '~> 3.4')
  s.add_development_dependency('pry-rails', '~> 0.3')
end
