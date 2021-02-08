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
          expect(mautic_contact.to_mautic).to include tags: ["another tag", "important"]
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

      context "stage" do
        describe "#stage" do
          subject { mautic_contact.stage }
          it "is object" do
            is_expected.to be_a Mautic::Stage
          end
          it "name" do
            expect(subject.name).to eq "stage1"
          end
        end
        describe "#stage_id" do
          subject { mautic_contact.stage_id }
          it { is_expected.to eq 1 }
        end

        describe "#stage=" do
          let(:stage_attributes) { { id: 7, name: "Test stage 7" } }
          context "object" do
            it "assigned directly" do
              mautic_contact.stage = Mautic::Stage.new(oauth2, stage_attributes)
              expect(mautic_contact.stage).to have_attributes stage_attributes
            end
          end
          context "hash" do
            it "build stage" do
              mautic_contact.stage = stage_attributes
              expect(mautic_contact.stage).to be_a Mautic::Stage
              expect(mautic_contact.stage).to have_attributes stage_attributes
            end
          end
        end

        describe "#ensure_stage" do
          before do
            stub_request(:patch, "#{oauth2.url}/api/contacts/1/edit").to_return(status: 200,
                                                                                body: contact.to_json,
                                                                                headers: { 'Content-Type' => 'application/json' }
            )
          end
          context "remove from stage" do
            let!(:stub) { stub_request(:post, "#{oauth2.url}/api/stages/1/contact/1/remove") }
            around do |example|
              example.run
              expect(mautic_contact.changes).to include stage_id: nil
              mautic_contact.save
              expect(stub).to have_been_made
              expect(mautic_contact.changes).not_to include :stage_id
            end
            it "stage=" do
              mautic_contact.stage = nil
            end
            it "stage_id=" do
              mautic_contact.stage_id = nil
            end
            context "fail" do
              let!(:stub) { stub_request(:post, "#{oauth2.url}/api/stages/1/contact/1/remove").and_return(status: 404) }
              it "stage_id=" do
                mautic_contact.stage_id = nil
              end
            end
          end
          context "add to stage" do
            let!(:stub) { stub_request(:post, "#{oauth2.url}/api/stages/7/contact/1/add") }
            around do |example|
              stub_request(:get, "#{oauth2.url}/api/stages/7").and_return(status: 200, body: file_fixture("stage.json").read)
              example.run
              expect(mautic_contact.changes).to include stage_id: 7
              mautic_contact.save
              expect(stub).to have_been_made
              expect(mautic_contact.changes).not_to include :stage_id
            end
            it "stage=" do
              mautic_contact.stage = Mautic::Stage.new(oauth2, id: 7, name: "Tralala")
            end
            it "stage_id=" do
              mautic_contact.stage_id = 7
            end
            context "fail" do
              let!(:stub) { stub_request(:post, "#{oauth2.url}/api/stages/7/contact/1/add").and_return(status: 404) }
              it "stage_id=" do
                mautic_contact.stage_id = 7
              end
            end
          end
        end
      end
    end

    describe "#campaigns" do
      let(:mautic_contact) { described_class.new oauth2, id: 1, firstname: "Test", lastname: "Contact" }

      def stub_with_response(status, hash)
        stub_request(:get, "#{oauth2.url}/api/contacts/1/campaigns").
          to_return(status: status,
                    body: hash.to_json,
                    headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "get list" do
        body = {
          total: 1,
          campaigns: {
            "1": {
              id: 1,
              name: "Welcome Campaign",
              dateAdded: "2015-07-21T14:11:47-05:00",
              manuallyRemoved: false,
              manuallyAdded: false,
              list_membership: [3]
            }
          }
        }
        stub = stub_with_response(200, body)
        expect(mautic_contact.campaigns).to include be_a(Mautic::Campaign)
        expect(stub).to have_been_made
      end

      it "list is empty" do
        stub = stub_with_response(200, { total: 0, campaigns: [] })
        expect(mautic_contact.campaigns).to eq []
        expect(stub).to have_been_made
      end

      it "something wrong" do
        stub_with_response(500, "Internal Server")
        expect(mautic_contact.campaigns).to eq []
      end
    end

  end

end
