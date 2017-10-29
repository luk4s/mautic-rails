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

      it '#chagnes' do
        klass = oauth2.contacts.instance_variable_get :@target
        entity = klass.new(oauth2.contacts, contact['contact'])
        expect(entity.twitter).to eq 'jimcontact'
        expect(entity.changes).to be_blank
        entity.firstname = Faker::Name.first_name
        expect(entity.changes).not_to be_blank
      end




    end


  end
end