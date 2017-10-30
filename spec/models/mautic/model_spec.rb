require 'pry-rails'
module Mautic
  RSpec.describe Mautic::Proxy do

    let(:oauth2) { FactoryBot.create(:oauth2) }

    context 'contacts' do

      let(:contact) do
        {
          "contact" =>
            {
              "id" => 47,
              "dateAdded" => "2015-07-21T12:27:12-05:00",
              "createdBy" => 1,
              "createdByUser" => "Joe Smith",
              "dateModified" => "2015-07-21T14:12:03-05:00",
              "modifiedBy" => 1,
              "modifiedByUser" => "Joe Smith",
              "points" => 10,
              "lastActive" => "2015-07-21T14:19:37-05:00",
              "dateIdentified" => "2015-07-21T12:27:12-05:00",
              "color" => "ab5959",
              "fields" => {
                "core" => {
                  "title" => {
                    "id" => "1",
                    "label" => "Title",
                    "alias" => "title",
                    "type" => "lookup",
                    "group" => "core",
                    "value" => "Mr"
                  },
                  "firstname" => {
                    "id" => "2",
                    "label" => "First Name",
                    "alias" => "firstname",
                    "type" => "text",
                    "group" => "core",
                    "value" => "Jim"
                  }
                },
                "social" => {
                  "twitter" => {
                    "id" => "17",
                    "label" => "Twitter",
                    "alias" => "twitter",
                    "type" => "text",
                    "group" => "social",
                    "value" => "jimcontact"
                  }
                },
                "personal" => [],
                "professional" => [],
                "all" => {
                  "title" => "Mr",
                  "firstname" => "Jim",
                  "twitter" => "jimcontact"
                }
              }
            }

        }
      end

      let(:model_contact) do
        'Mautic::Contact'.safe_constantize || Mautic.const_set('Contact', Class.new(Mautic::Model))
      end

      it '#chagnes' do
        klass = oauth2.contacts.instance_variable_get :@target
        entity = klass.new(oauth2.contacts, contact['contact'])
        expect(entity.twitter).to eq 'jimcontact'
        expect(entity.changes).to be_blank
        entity.firstname = Faker::Name.first_name
        expect(entity.changes).not_to be_blank
      end

      it '#create' do
        attributes = { firstname: Faker::Name.first_name, email: Faker::Internet.email }
        stub = stub_request(:post, "#{oauth2.url}/api/contacts/new").
          with(body: hash_including(attributes),
               headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }).
          to_return({ status: 200,
                      body: { contact: { id: rand(99) }.merge(attributes) }.to_json,
                      headers: { 'Content-Type' => 'application/json' }
                    })
        contact = Mautic::Contact.new(oauth2, attributes)
        contact = oauth2.contacts.new(attributes)
        contact.lastname = 'Lukas'
        expect(contact.save).to eq true

        expect(stub).to have_been_made
      end

      it '#destroy' do
        stub = stub_request(:get, "#{oauth2.url}/api/contacts/1")
                 .and_return({
                               status: 200,
                               body: { contact: { id: 1 } }.to_json,
                               headers: { 'Content-Type' => 'application/json' }
                             })

        destroy = stub_request(:delete, "#{oauth2.url}/api/contacts/1/delete")
                    .and_return({
                                  status: 200,
                                  body: '{}',
                                  headers: { 'Content-Type' => 'application/json' }
                                })
        contact = Mautic::Contact.in(oauth2).find(1)
        expect(stub).to have_been_made
        expect(contact.destroy).to eq true
        expect(destroy).to have_been_made

      end


    end


  end
end