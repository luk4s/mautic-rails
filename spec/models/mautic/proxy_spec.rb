module Mautic
  RSpec.describe Mautic::Proxy do
    let(:oauth2) { FactoryBot.create(:oauth2, token: Faker::Internet.password, refresh_token: Faker::Internet.password) }
    let(:contacts) do
      {
        "total" => "1",
        "contacts" => {"47" =>
          {
            "id" => 47,
            "isPublished" => true,
            "dateAdded" => "2015-07-21T12:27:12-05:00",
            "createdBy" => 1,
            "createdByUser" => "Joe Smith",
            "dateModified" => "2015-07-21T14:12:03-05:00",
            "modifiedBy" => 1,
            "modifiedByUser" => "Joe Smith",
            "owner" => {
              "id" => 1,
              "username" => "joesmith",
              "firstName" => "Joe",
              "lastName" => "Smith"
            },
            "points" => 10,
            "lastActive" => "2015-07-21T14:19:37-05:00",
            "dateIdentified" => "2015-07-21T12:27:12-05:00",
            "color" => "ab5959",
            "ipAddresses" => {
              "111.111.111.111" => {
                "ipAddress" => "111.111.111.111",
                "ipDetails" => {
                  "city" => "",
                  "region" => "",
                  "country" => "",
                  "latitude" => "",
                  "longitude" => "",
                  "isp" => "",
                  "organization" => "",
                  "timezone" => ""
                }
              }
            },
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
      }
    end
    let(:contact) do
      {
        "contact" =>
          {
            "id" => 47,
            "isPublished" => true,
            "dateAdded" => "2015-07-21T12:27:12-05:00",
            "createdBy" => 1,
            "createdByUser" => "Joe Smith",
            "dateModified" => "2015-07-21T14:12:03-05:00",
            "modifiedBy" => 1,
            "modifiedByUser" => "Joe Smith",
            "owner" => {
              "id" => 1,
              "username" => "joesmith",
              "firstName" => "Joe",
              "lastName" => "Smith"
            },
            "points" => 10,
            "lastActive" => "2015-07-21T14:19:37-05:00",
            "dateIdentified" => "2015-07-21T12:27:12-05:00",
            "color" => "ab5959",
            "ipAddresses" => {
              "111.111.111.111" => {
                "ipAddress" => "111.111.111.111",
                "ipDetails" => {
                  "city" => "",
                  "region" => "",
                  "country" => "",
                  "latitude" => "",
                  "longitude" => "",
                  "isp" => "",
                  "organization" => "",
                  "timezone" => ""
                }
              }
            },
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
require "pry-rails"
    context 'expire' do
      let(:expire_response) do
        { "errors" =>
            [{ "message" => "The access token provided has expired.", "code" => 401, "type" => "invalid_grant" }]
        }
      end

      it 'get request after expiration' do
        stub1 = stub_request(:get, "#{oauth2.url}/api/contacts")
                  .with(headers: { 'Authorization' => "Bearer #{oauth2.access_token}" })
                  .and_return({
                                status: 200,
                                body: expire_response.to_json,
                                headers: { 'Content-Type' => 'application/json' }
                              })
        new_access_token = Faker::Internet.password
        stub2 = stub_request(:post, "#{oauth2.url}/oauth/v2/token")
                  .and_return({
                                body: {
                                  access_token: new_access_token,
                                  refresh_token: Faker::Internet.password
                                }.to_param,
                                headers: { 'Content-Type': 'application/x-www-form-urlencoded' } })

        stub3 = stub_request(:get, "#{oauth2.url}/api/contacts")
                  .with(headers: { 'Authorization' => "Bearer #{new_access_token}" })
                  .and_return({
                                status: 200,
                                body: { "contacts" => [] }.to_json,
                                headers: { 'Content-Type' => 'application/json', }
                              })

        expect { oauth2.contacts.all }.not_to raise_error

        expect(oauth2.reload.token).to eq(new_access_token)

        expect(stub1).to have_been_requested
        expect(stub2).to have_been_requested
        expect(stub3).to have_been_requested
      end
    end

    it '#all' do
      stub = stub_request(:get, oauth2.url + '/api/contacts')
               .and_return({
                             status: 200,
                             body: contacts.to_json,
                             headers: { 'Content-Type' => 'application/json' }
                           })
      contacts = []
      expect { contacts = oauth2.contacts.all }.not_to raise_error
      expect(stub).to have_been_made
      expect(contacts.size).to eq 1
    end

    it '#find' do
      stub = stub_request(:get, "#{oauth2.url}/api/contacts/47")
               .and_return({
                             status: 200,
                             body: contact.to_json,
                             headers: { 'Content-Type' => 'application/json' }
                           })
      contact = nil
      expect { contact = oauth2.contacts.find(47) }.not_to raise_error
      expect(stub).to have_been_made
      expect(contact.firstname).to eq 'Jim'
    end


  end
end