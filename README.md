# Mautic rails
[![Maintainability](https://api.codeclimate.com/v1/badges/c8cd605b5e021fb841d1/maintainability)](https://codeclimate.com/github/luk4s/mautic-rails/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/c8cd605b5e021fb841d1/test_coverage)](https://codeclimate.com/github/luk4s/mautic-rails/test_coverage)
 
RoR helper / wrapper for Mautic API and forms

*Rails 6.0+ compatible*
*Ruby 3.1+ compatible*

## Installation
Add this line to your application's Gemfile:

```ruby
gem "mautic", "~> 3.1"
```

And then execute:
```bash
$ bundle
```
Also you need migrate database:
```bash
$ rails db:migrate
```

## Configuration

add to `config/initializers/mautic.rb`:
```ruby
Mautic.configure do |config|
  # This is for oauth handshake token url. I need to know where your app listen
  config.base_url = "https://my-rails-app.com"
  # OR it can be Proc 
  # *optional* This is your default mautic URL - used in form helper 
  config.mautic_url = "https://mautic.my.app"
  # Set authorize condition for manage Mautic::Connections
  config.authorize_mautic_connections = ->(controller) { false }
end
```
### Manage mautic connections
You can use builtin Mautic:ConnectionsController:

add to `config/routes.rb`
```ruby
mount Mautic::Engine => "/mautic"
```
note: Make sure that you have some user authorization. There is builtin mechanism, in `Mautic.config.authorize_mautic_connections` = which return `false` to prevent all access by default (see: app/controllers/mautic/connections_controller.rb:3). For change this, you need add to `config/initializers/mautic.rb`:
```ruby
Mautic.config.authorize_mautic_connections = ->(controller) { current_user.admin? }
```

OR use your own controller, by including concern 
```ruby
class MyOwnController < ApplicationController
  before_action :authorize_user

  include Mautic::ConnectionsControllerConcern
end
```
Concern require additional routes (authorize and oauth2) in `routes.rb`
```ruby
resources :my_resources do
  member do
    get :authorize
    get :oauth2
  end
end
```

### Create mautic connection
  
1. In your mautic, create new
2. Got to `/your-mount-point/connections`
3. Create new connection - enter URL to your mautic
4. Copy `callback url` then go to you mautic

      > In mautic you need add API oauth2 login.

      > ```
      > http://localhost:3000/mautic/connections/:ID/oauth2
      > ```
      > ID = is your Mautic::Connection ID
          
5. Create new **Oauth2** API connections. Use `callback url` from previous step and copy `key` and `secret` to form in your app
6. Update and use `Authorize`  button for handshake

> For example of integration check https://github.com/luk4s/redmine_mautic
      
     
## Usage

   Find connection which you want to use:
  ```ruby
  m = Mautic::Connection.last
  ```
  Get specify contact:
  ```ruby
  contact = m.contact.find(1) # => #<Mautic::Contact id=1 ...>
  ```
  Collections of contacts:
  ```ruby
  m.contacts.where(search: "gmail").each do |contact|
    #<Mautic::Contact id=12 ...>
    #<Mautic::Contact id=21 ...>
    #<Mautic::Contact id=99 ...>
  end
  ```
  New instance of contacts:
  ```ruby
  contact = m.contacts.new({ email: "newcontactmail@fake.info"} )
  contact.save # => true
  ```
  Update contact
  ```ruby
  contact.email = ""
  contact.save # => false
  contact.errors # => [{"code"=>400, "message"=>"email: This field is required.", "details"=>{"email"=>["This field is required."]}}]
  ```
  #### Do not contact
  ```ruby
  contact.do_not_contact? # => false
  contact.do_not_contact! message: "Some reason"
  contact.do_not_contact? # => true
  ```
  Remove do not contact
  ```ruby
  contact.do_not_contact? # => true
  contact.remove_do_not_contact!
  contact.do_not_contact? # => false
  ```
  #### Campaigns
  list of contacts campaigns (where contact is a member) and remove it from one
  ```ruby
  contact.campaigns #=> [Mautic::Campaign, ...]
  campaign = contact.campaigns.find { |campaign| campaign.name == "Newsletter" }
  campaign.remove_contact! contact.id
  ```
  or add contact back
  ```ruby
  campaign = connection.campaigns.where(search: "Newsletter").first
  campaign.add_contact! contact.id
  ```
  Of course you can use more than contact: `assets`, `emails`, `companies`, `forms`, `points` ...
### Gem provides simple Mautic form submit
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
  
### Webhook receiver
Receive webhook from mautic, parse it and prepare for use.

  1. add concern to your controller
      
          include Mautic::ReceiveWebHooks
  2. in routes must be specify `:mautic_id`, for example:
  
          post "webhook/:mautic_id", action: "webhook", on: :collection
          
## Contributing
Ideas and pull requests are welcome!

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
