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
          to_return(status: 200,
                    body: { contact: { id: rand(99) }.merge(attributes) }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
          )
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
          to_return(status: 400,
                    body: { contact: { id: rand(99) }.merge(attributes) }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
          )
        contact = oauth2.contacts.new(attributes)
        contact.lastname = 'Lukas'
        expect(contact.save).to eq true

        expect(stub).to have_been_made
      end

    end

    context '#destroy' do
      it 'exists record' do
        stub = stub_request(:get, "#{oauth2.url}/api/contacts/1")
                 .and_return(
                   status: 200,
                   body: { contact: { id: 1 } }.to_json,
                   headers: { 'Content-Type' => 'application/json' }
                 )

        destroy = stub_request(:delete, "#{oauth2.url}/api/contacts/1/delete")
                    .and_return(
                      status: 200,
                      body: '{}',
                      headers: { 'Content-Type' => 'application/json' }
                    )
        contact = described_class.in(oauth2).find(1)
        expect(stub).to have_been_made
        expect(contact.destroy).to eq true
        expect(destroy).to have_been_made
      end

      it 'record not found' do
        stub = stub_request(:get, "#{oauth2.url}/api/contacts/1")
                 .and_return(
                   status: 200,
                   body: { contact: { id: 1 } }.to_json,
                   headers: { 'Content-Type' => 'application/json' }
                 )

        destroy = stub_request(:delete, "#{oauth2.url}/api/contacts/1/delete")
                    .and_return(
                      status: 404,
                      body: { errors: [{ code: 404, message: 'not found' }] }.to_json,
                      headers: { 'Content-Type' => 'application/json' }
                    )
        contact = described_class.in(oauth2).find(1)
        expect(stub).to have_been_made
        expect(contact.destroy).to eq false
        expect(destroy).to have_been_made
        expect(contact.errors).to eq ['not found']
      end
    end

    it '#attributes' do
      _stub = stub_request(:get, "#{oauth2.url}/api/contacts/1")
                .and_return(
                  status: 200,
                  body: contact.to_json,
                  headers: { 'Content-Type' => 'application/json' }
                )
      contact = described_class.in(oauth2).find(1)
      expect(contact.attributes).to include *%i(created_at title firstname)
    end

    context '#save' do

      it 'invalid' do
        stub = stub_request(:patch, "#{oauth2.url}/api/contacts/1/edit")
                 .with(body: hash_including(email: "null", country: "null"))
                 .and_return(
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
                 )
        contact = described_class.new(oauth2, id: 1)
        contact.attributes = { email: 'null', country: 'null' }
        expect { contact.update }.not_to raise_exception
        expect(stub).to have_been_made
        expect(contact.errors).to be_kind_of Hash
        expect(contact.errors.keys).to include *%w(email country)
      end

    end

    describe "#update_columns" do
      it do
        stub = stub_request(:patch, "#{oauth2.url}/api/contacts/1/edit").with(body: { owner: "3" })
        contact = described_class.new(oauth2, id: 1)
        contact.attributes = { email: 'null', country: 'null' }
        expect { contact.update_columns(owner: 3) }.not_to raise_exception
        expect(stub).to have_been_made
        expect(contact.errors).to be_blank
      end
    end

    context 'with instance' do

      let(:mautic_contact) do
        _stub = stub_request(:get, "#{oauth2.url}/api/contacts/1")
                  .and_return(
                    status: 200,
                    body: contact.to_json,
                    headers: { 'Content-Type' => 'application/json' }
                  )
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

      it '#mautic_id' do
        expect(mautic_contact.mautic_id).to eq "#{mautic_contact.id}/#{oauth2.id}"
      end

      describe '#tags' do
        subject { mautic_contact.tags }

        it 'its array' do
          is_expected.to be_a Array
        end

        it 'include tag with name ' do
          is_expected.to include(Mautic::Tag.new(oauth2, id: 1, tag: "important"))
        end

        it "to_mautic should be values" do
          expect(mautic_contact.to_mautic).to include tags: "important"
        end
      end

      it "#events" do
        expect(mautic_contact.events).to be_a Proxy
      end

      it "#to_mautic" do
        mautic_contact.multiple_cf = %w[a b]
        mautic_contact.nil_value = nil
        expect(mautic_contact.to_mautic).to include multiple_cf: "a|b", nil_value: nil
      end

      context 'do not contact' do
        describe '#do_not_contact' do
          subject { mautic_contact.do_not_contact }
          it do
            is_expected.to be_a Array
            expect(subject[0]).to eq bounced: "Invalid"
          end
        end

        describe '#bounced?' do
          it { expect(mautic_contact.bounced?).to eq true }
        end

        describe '#unsubscribed?' do
          it { expect(mautic_contact.unsubscribed?).to eq false }
        end

        describe '#do_not_contact?' do
          it { expect(mautic_contact.do_not_contact?).to eq true }
        end

        describe 'do_not_contact!' do
          subject { mautic_contact.do_not_contact!(comments: "bother me") }

          it "failed" do
            stub_request(:post, "#{oauth2.url}/api/contacts/1/dnc/email/add")
              .and_return(
                status: 400,
                body: {
                  "errors" =>
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
              )
            is_expected.to eq false
          end

          context "reload do_not_contact" do
            let(:contact) do
              json = JSON.parse(file_fixture("contact.json").read)
              json["contact"].delete("doNotContact")
              json
            end
            it do
              dnc_response = JSON.parse(file_fixture("contact.json").read)
              dnc_response["contact"]["doNotContact"] = [{ "id" => 666, "reason" => 3, "comments" => "Dont like him.", "channel" => "web", "channelId" => 9 }]
              expect(mautic_contact.dnc?).to eq false
              stub_request(:post, "#{oauth2.url}/api/contacts/1/dnc/email/add")
                .and_return(
                  status: 200,
                  body: dnc_response.to_json,
                  headers: { 'Content-Type' => 'application/json' }
                )
              is_expected.to eq true
              expect(mautic_contact.dnc?).to eq true
              expect(mautic_contact.unsubscribed?).to eq false
              expect(mautic_contact.bounced?).to eq false
            end
          end
        end

        describe 'remove_do_not_contact!' do
          subject { mautic_contact.remove_do_not_contact! }

          it "failed" do
            stub_request(:post, "#{oauth2.url}/api/contacts/1/dnc/email/remove")
              .and_return(
                status: 400,
                body: {
                  "errors" =>
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
              )
            is_expected.to eq false
          end

          context "reload do_not_contact" do
            let(:contact_with_do_not_contact) do
              json = JSON.parse(file_fixture("contact.json").read)
              json["contact"].delete("doNotContact")
              json
            end
            it do
              expect(mautic_contact.dnc?).to eq true
              stub_request(:post, "#{oauth2.url}/api/contacts/1/dnc/email/remove")
                .and_return(
                  status: 200,
                  body: contact_with_do_not_contact.to_json,
                  headers: { 'Content-Type' => 'application/json' }
                )
              is_expected.to eq true
              expect(mautic_contact.dnc?).to eq false
            end
          end
        end

      end

      context "owner" do
        describe "#owner" do
          subject { mautic_contact.owner }
          it "should be hash" do
            is_expected.to be_a Hash
          end
          it "has keys id, firstName, lastName" do
            is_expected.to include *%w[id firstName lastName]
          end
        end

        describe "#owner=" do
          it do
            mautic_contact.owner = { id: 12 }
          end
          it "wrong type raise ArgumentError" do
            expect { mautic_contact.owner = spy }.to raise_error ArgumentError
          end
        end

        it "owner update" do
          mautic_contact.owner_id = 77

          stub = stub_request(:patch, "#{oauth2.url}/api/contacts/1/edit").with(body: hash_including("owner" => "77"))
                   .and_return(
                     status: 200,
                     body: { contact: { owner: { id: 77, firstName: "Tik", lastName: "Tak" } } }.to_json,
                     headers: { 'Content-Type' => 'application/json' }
                   )

          mautic_contact.save
          expect(stub).to have_been_made

          expect(mautic_contact.owner).to include "id" => 77, "firstName" => "Tik"
        end
      end
    end

  end

end
