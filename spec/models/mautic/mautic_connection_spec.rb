require 'rails_helper'

module Mautic
  RSpec.describe Connections::Oauth2 do
    let(:oauth2) { FactoryBot.create(:oauth2, token: Faker::Internet.password, refresh_token: Faker::Internet.password) }

    it '#refresh' do
      stub = stub_request(:post, "#{oauth2.url}/oauth/v2/token").with(body: {
        client_id: oauth2.client_id,
        client_secret: oauth2.secret,
        grant_type: 'refresh_token',
        refresh_token: oauth2.refresh_token
      }).to_return(status: 200,
                   body: {
                     access_token: Faker::Internet.password,
                     refresh_token: Faker::Internet.password
                   }.to_param,
                   headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })

      oauth2.refresh!
      expect(stub).to have_been_made
    end
  end
end
