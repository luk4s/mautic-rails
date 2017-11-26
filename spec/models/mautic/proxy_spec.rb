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

    context 'expire' do
      let(:expire_response) do
        { "errors" =>
            [{ "message" => "The access token provided has expired.", "code" => 401, "type" => "invalid_grant" }]
        }
      end

      it 'get request after expiration' do
        stub1 = stub_request(:get, /#{oauth2.url}\/api\/contacts.*/)
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

        stub3 = stub_request(:get, /#{oauth2.url}\/api\/contacts.*/)
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

    context 'contacts' do
      it '#all' do
        stub = stub_request(:get, /#{oauth2.url}\/api\/contacts.*/)
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

      context '#find' do

        it 'item found' do
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

        it 'not found' do
          stub = stub_request(:get, "#{oauth2.url}/api/contacts/1")
                   .and_return({
                                 status: 404,
                                 body: {errors: [code: 404]}.to_json,
                                 headers: { 'Content-Type' => 'application/json' }
                               })
          contact = nil
          expect { contact = oauth2.contacts.find(1) }.to raise_error Mautic::RecordNotFound
          expect(stub).to have_been_made
        end

      end

      it '#all paginate' do
        r = {}
        30.times {|i| r[i.to_s] = {'id' => i.to_s}}
        stub = stub_request(:get, /#{oauth2.url}\/api\/contacts.*/)
                 .and_return({
                               status: 200,
                               body: {'total' => '99', 'contacts' => r }.to_json,
                               headers: { 'Content-Type' => 'application/json' }
                             })
        contacts = []
        expect { contacts = oauth2.contacts.all(limit: 'all') }.not_to raise_error
        expect(stub).to have_been_requested.times(4)
        expect(contacts.size >= 99).to be_truthy
      end

      it '#all with block with paginate' do
        stub1 = stub_request(:get, "#{oauth2.url}/api/contacts?search=!is:anonymous")
                 .and_return({
                               status: 200,
                               body: {
                                 'total' => '54',
                                 'contacts' => (1..30).inject({}){|mem,var| mem[var.to_s] = {'id' => var}; mem}
                               }.to_json,
                               headers: { 'Content-Type' => 'application/json' }
                             })
        stub2 = stub_request(:get, "#{oauth2.url}/api/contacts?search=!is:anonymous&start=30")
                  .and_return({
                                status: 200,
                                body: {
                                  'total' => '54',
                                  'contacts' => (31..54).inject({}){|mem,var| mem[var.to_s] = {'id' => var}; mem}
                                }.to_json,
                                headers: { 'Content-Type' => 'application/json' }
                              })
        index = 0
        contacts = oauth2.contacts.all(limit: 'all') do |contact|
          index += 1
          expect(contact.id).to eq index
        end
        expect(index).to eq 54
        expect(stub1).to have_been_requested.times(1)
        expect(stub2).to have_been_requested.times(1)
        expect(contacts.size).to eq 54
      end

      it '#all with block without pagination' do
        stub1 = stub_request(:get, "#{oauth2.url}/api/contacts?search=!is:anonymous")
                  .and_return({
                                status: 200,
                                body: {
                                  'total' => '22',
                                  'contacts' => (1..22).inject({}){|mem,var| mem[var.to_s] = {'id' => var}; mem}
                                }.to_json,
                                headers: { 'Content-Type' => 'application/json' }
                              })
        index = 0
        contacts = oauth2.contacts.all(limit: 'all') do |contact|
          index += 1
          expect(contact.id).to eq index
        end
        expect(index).to eq 22
        expect(stub1).to have_been_requested.times(1)
        expect(contacts.size).to eq 22
      end

      context 'default_params' do

        it '#all limit=1' do
          stub = stub_request(:get, "#{oauth2.url}/api/contacts?limit=1&search=!is:anonymous")
                   .and_return({
                                 status: 200,
                                 body: {'total' => 1, 'contacts' => {'1' => {'id' => 1}}}.to_json,
                                 headers: { 'Content-Type' => 'application/json' }
                               })
          oauth2.contacts.all(limit: 1)
          Mautic::Contact.in(oauth2).all(limit: 1)
          expect(stub).to have_been_made.times 2
        end

      end
    end

    context 'forms' do
      let(:forms) do
        {
          "total" => 1,
          "forms" => [
            {
              "id" => 3,
              "name" => "Newlsetter",
              "alias" => "newsletter",
              "isPublished" => true,
              "dateAdded" => "2015-07-15T15:06:02-05:00",
              "createdBy" => 1,
              "createdByUser" => "Joe Smith",
              "dateModified" => "2015-07-20T13:11:56-05:00",
              "modifiedBy" => 1,
              "modifiedByUser" => "Joe Smith",
              "cachedHtml" => "\n\n<script...",
              "submissionCount" => 10,
              "fields" => {
                "26" => {
                  "id" => 26,
                  "label" => "Email",
                  "showLabel" => false,
                  "alias" => "email",
                  "type" => "text",
                  "isRequired" => true,
                  "validationMessage" => "Email is required",
                  "order" => 1,
                  "properties" => {
                    "placeholder" => "Email address"
                  }},
                "27" => {
                  "id" => 27,
                  "label" => "Submit",
                  "showLabel" => true,
                  "alias" => "submit",
                  "type" => "button",
                  "isRequired" => false,
                  "order" => 4,
                  "properties" => []}
              },
              "actions" => {
                "4" => {
                  "id" => 4,
                  "type" => "email.send.lead",
                  "name" => "Send thank you email",
                  "order" => 1,
                  "properties" => {
                    "email" => 21
                  }
                }
              }
            }
          ]
        }
      end
      let(:model_form) do
        'Mautic::Form'.safe_constantize || Mautic.const_set('Form', Class.new(Mautic::Model))
      end

      it '#all' do
        stub = stub_request(:get, oauth2.url + '/api/forms')
                 .and_return({
                               status: 200,
                               body: forms.to_json,
                               headers: { 'Content-Type' => 'application/json' }
                             })
        forms = []
        expect { forms = oauth2.forms.all }.not_to raise_error
        expect(stub).to have_been_made
        expect(forms.size).to eq 1
      end
    end

  end
end