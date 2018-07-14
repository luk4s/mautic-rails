require 'rails_helper'

module Mautic

  RSpec.describe Mautic::Connection do
    context 'not implemented' do
      let(:conn) { described_class.new }
      it '#client' do
        expect { conn.client }.to raise_exception NotImplementedError
      end

      it '#authorize' do
        expect { conn.authorize }.to raise_exception NotImplementedError
      end

      it '#get_code' do
        expect { conn.get_code(SecureRandom.hex 4) }.to raise_exception NotImplementedError
      end

      it '#connection' do
        expect { conn.connection }.to raise_exception NotImplementedError
      end
      it '#refresh!' do
        expect { conn.refresh! }.to raise_exception NotImplementedError
      end

      it '#request' do
        expect { conn.request(:get, '/api/', {}) }.to raise_exception NotImplementedError
      end
    end

    describe '#callback_url' do
      subject { described_class.new.send(:callback_url) }
      it 'default' do
        is_expected.to be_a URI
      end

      it 'with proc config' do
        original = Mautic.config.base_url
        Mautic.config.base_url = ->(_) { "https://xxxx.com" }
        is_expected.to eq URI.parse("https://xxxx.com")
        Mautic.config.base_url = original
      end
    end
  end
  RSpec.describe Connections::Oauth2 do
    include_context 'connection'

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

      it 'RequestError' do
        stub = stub_request(:get, "#{oauth2.url}/data").to_return({
                                                                            status: 422,
                                                                            body: 'payment required',
                                                                            headers: { 'Content-Type' => 'text/plain' }})
        expect{oauth2.request(:get, 'data')}.to raise_exception Mautic::RequestError
        expect(stub).to have_been_made
      end


    end
  end
end
