require 'rails_helper'

module Mautic
  RSpec.describe FormHelper do

    it '#send_data' do
      m = FormHelper.new("https://mautic.fake.com")
      stub = stub_request(:post, "#{m.url}/form/submit")
               .with(body: hash_including("mauticform" => hash_including("name"))).to_return(status: 302)

      m.send_data 1 do |i|
        i.name = Faker::Name.first_name
        i.email = Faker::Internet.free_email
      end
      expect(stub).to have_been_made
    end

    it '#push' do
      m = FormHelper.new("https://mautic.fake.com")
      stub = stub_request(:post, "#{m.url}/form/submit")
               .with(body: hash_including("mauticform" => hash_including("name"))).to_return(status: 302)
      m.data = {name: Faker::Name.first_name, email: Faker::Internet.free_email}
      m.submit
      expect(stub).to have_been_made
    end

    it '.submit' do
      stub = stub_request(:post, "https://mautic.my.app/form/submit")
               .with(body: hash_including("mauticform" => hash_including("name", "domain"))).to_return(status: 302)

      FormHelper.submit(form: 13, request: OpenStruct.new(host: Faker::Internet.domain_name)) do |i|
        i.name = Faker::Name.first_name
        i.email = Faker::Internet.free_email
      end

      expect(stub).to have_been_made
    end

  end
end
