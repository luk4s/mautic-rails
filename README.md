# Mautic rails 
RoR helper / wrapper for Mautic API and forms

## Usage
* Gem provides API connection to your Mautic(s)
  1. Create mautic connection
  2. Authorize it
  3. 
  ```ruby
  m = Mautic::MauticConnection.last
  m.connection.get("api/contacts") # => return contacts from your mautic
  ```
* Gem provides simple Mautic form submit.
There are two options of usage:
  1. Use default mautic url from configuration and shortcut class method:
    ```ruby
    # form: ID of form in Mautic *required*
    # url: Mautic URL - default is from configuration
    # request: request object (for domain, and forward IP...) *optional*
    Mautic::FormHelper.submit(form: "mautic form ID") do |i|
      i.form_field1 = "value1"
      i.form_field2 = "value2"
    end
    ``` 
  2. Or create instance
  ```ruby
  # request is *optional*
  m = Mautic::FormHelper.new("https://mymautic.com", request)
  m.data = {} # hash of attributes
  m.push # push data to mautic 
  ```

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
  config.base_url = "https:://my-rails-app.com"
  # *optional* This is your default mautic URL - used in form helper 
  config.mautic_url = "https://mautic.my.app"
end
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
