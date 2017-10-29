# Mautic rails 
RoR for Mautic API

## Usage
* Gem provides API connection to your Mautic(s)

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'mautic'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install mautic
```

## Configuration

add to `config/initializers/mautic.rb`:
```ruby
Mautic.configure do |config|
  # This is for oauth handshake token url. I need to know where your app listen
  config.base_url = "https://my-rails-app.com" 
end
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
