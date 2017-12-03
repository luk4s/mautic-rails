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

    context 'exceptions' do
      let(:response_ok) do
        { "contact" => { "id" => 47 } }
      end

      let(:response_token_expired) do
        {
          "errors" => [{ "message" => "Autorizace rozhraní API byla odepřena.", "code" => 401, "type" => "access_denied" }]
        }
      end

      let(:response_not_found) do
        { "errors" => [{ "code" => 404, "message" => "Položka nebyla nalezena.", "details" => [] }] }
      end

      let(:response_no_route) do
        {
          "errors" => [{ "message" => "Zdá se, že jsem narazil na chybu (chyba 404). Pokud to udělám znovu, nahlašte mě prosím správci systému!", "code" => 404, "type" => nil }]
        }
      end

      let(:response_validation_error) do
        {
          "errors" =>
            [
              { "code" => 400,
                "message" => "email: Musí být zadán platný e-mail.",
                "details" => { "email" => ["Musí být zadán platný e-mail."] } }
            ]
        }
      end

      it 'TokenExpiredError' do
        stub_request(:get, "#{oauth2.url}/api/contacts/1").to_return({
          status: 200,
          body: response_token_expired.to_json,
          headers: { 'Content-Type' => 'application/json' }})

        stub = stub_request(:post, "#{oauth2.url}/oauth/v2/token").with(body: {
          client_id: oauth2.client_id,
          client_secret: oauth2.secret,
          grant_type: 'refresh_token',
          refresh_token: oauth2.refresh_token
        }).to_return(status: 200,
                     body: response_token_expired.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect{oauth2.request(:get, 'api/contacts/1')}.to raise_exception Mautic::TokenExpiredError
        expect(stub).to have_been_made
      end

      it 'ValidationError' do
        stub = stub_request(:patch, "#{oauth2.url}/api/contacts/1/edit").to_return({
                                                                       status: 400,
                                                                       body: response_validation_error.to_json,
                                                                       headers: { 'Content-Type' => 'application/json' }})
        expect{ oauth2.request(:patch, 'api/contacts/1/edit', { body: { email: 'null' }}) }.to raise_exception ValidationError
        expect(stub).to have_been_made
      end

      context 'RecordNotFound' do

        it 'correct url' do
          stub = stub_request(:get, "#{oauth2.url}/api/contacts/1").to_return({
                                                                         status: 404,
                                                                         body: response_not_found.to_json,
                                                                         headers: { 'Content-Type' => 'application/json' }})
          expect{oauth2.request(:get, 'api/contacts/1')}.to raise_exception Mautic::RecordNotFound
          expect(stub).to have_been_made
        end

        it 'non-exist url' do
          stub = stub_request(:get, "#{oauth2.url}/api/blabla/1").to_return({
                                                                                status: 200,
                                                                                body: response_no_route.to_json,
                                                                                headers: { 'Content-Type' => 'application/json' }})
          expect{oauth2.request(:get, 'api/blabla/1')}.to raise_exception Mautic::RecordNotFound
          expect(stub).to have_been_made
        end

      end


    end
  end
end
