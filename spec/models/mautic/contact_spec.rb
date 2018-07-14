require 'pry-rails'
module Mautic
  RSpec.describe Contact do
    include_context 'connection'
    include_context 'contact'

    it '#changes' do
      klass = oauth2.contacts.instance_variable_get :@target
      entity = klass.new(oauth2.contacts, contact['contact'])
      expect(entity.twitter).to eq 'jimcontact'
      expect(entity.changes).to be_blank
      entity.firstname = Faker::Name.first_name
      expect(entity.changes).not_to be_blank
    end
    context '#create' do

      it 'valid' do
        attributes = { firstname: Faker::Name.first_name, email: Faker::Internet.email }
        stub = stub_request(:post, "#{oauth2.url}/api/contacts/new").
          with(body: hash_including(attributes),
               headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }).
          to_return({ status: 200,
                      body: { contact: { id: rand(99) }.merge(attributes) }.to_json,
                      headers: { 'Content-Type' => 'application/json' }
                    })
        contact = described_class.new(oauth2, attributes)
        contact = oauth2.contacts.new(attributes)
        contact.lastname = 'Lukas'
        expect(contact.save).to eq true

        expect(stub).to have_been_made
      end

      it 'invalid' do
        attributes = { firstname: Faker::Name.first_name, email: '_null' }
        stub = stub_request(:post, "#{oauth2.url}/api/contacts/new").
          with(body: hash_including(attributes),
               headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }).
          to_return({ status: 400,
                      body: { contact: { id: rand(99) }.merge(attributes) }.to_json,
                      headers: { 'Content-Type' => 'application/json' }
                    })
        contact = described_class.new(oauth2, attributes)
        contact = oauth2.contacts.new(attributes)
        contact.lastname = 'Lukas'
        expect(contact.save).to eq true

        expect(stub).to have_been_made
      end

    end

    context '#destroy' do
      it 'exists record' do
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
        contact = described_class.in(oauth2).find(1)
        expect(stub).to have_been_made
        expect(contact.destroy).to eq true
        expect(destroy).to have_been_made
      end

      it 'record not found' do
        stub = stub_request(:get, "#{oauth2.url}/api/contacts/1")
                 .and_return({
                               status: 200,
                               body: { contact: { id: 1 } }.to_json,
                               headers: { 'Content-Type' => 'application/json' }
                             })

        destroy = stub_request(:delete, "#{oauth2.url}/api/contacts/1/delete")
                    .and_return({
                                  status: 404,
                                  body: { errors: [{ code: 404, message: 'not found' }] }.to_json,
                                  headers: { 'Content-Type' => 'application/json' }
                                })
        contact = described_class.in(oauth2).find(1)
        expect(stub).to have_been_made
        expect(contact.destroy).to eq false
        expect(destroy).to have_been_made
        expect(contact.errors).to eq ['not found']
      end
    end

    it '#attributes' do
      _stub = stub_request(:get, "#{oauth2.url}/api/contacts/1")
                .and_return({
                              status: 200,
                              body: contact.to_json,
                              headers: { 'Content-Type' => 'application/json' }
                            })
      contact = described_class.in(oauth2).find(1)
      expect(contact.attributes).to include *%i(created_at title firstname)
    end

    context '#save' do

      it 'invalid' do
        stub = stub_request(:patch, "#{oauth2.url}/api/contacts/1/edit")
                 .and_return({
                               status: 400,
                               body: { "errors" =>
                                         [
                                           { "code" => 400,
                                             "message" => "email: Musí být zadán platný e-mail., country: Tato hodnota není platná.",
                                             "details" => {
                                               "email" => ["Musí být zadán platný e-mail."],
                                               "country" => ["Tato hodnota není platná."]
                                             }
                                           }]
                               }.to_json,
                               headers: { 'Content-Type' => 'application/json' }
                             })
        contact = described_class.new(oauth2, { id: 1 })
        contact.attributes = { email: 'null', country: 'null' }
        expect { contact.update }.not_to raise_exception
        expect(stub).to have_been_made
        expect(contact.errors).to be_kind_of Hash
        expect(contact.errors.keys).to include *%w(email country)
      end
    end

    context 'with instance' do

      let(:mautic_contact) do
        _stub = stub_request(:get, "#{oauth2.url}/api/contacts/1")
                  .and_return({
                                status: 200,
                                body: contact.to_json,
                                headers: { 'Content-Type' => 'application/json' }
                              })
        described_class.in(oauth2).find(1)
      end

      it '#name' do
        expect(mautic_contact.name).to eq 'Jim Joe'
      end


      it '#first_name' do
        expect(mautic_contact.firstname).to eq mautic_contact.first_name
        mautic_contact.first_name = 'sunshine'
        expect(mautic_contact.firstname).to eq 'sunshine'
      end

      it '#last_name' do
        expect(mautic_contact.lastname).to eq mautic_contact.last_name
      end

    end



  end

end