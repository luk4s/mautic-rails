module Mautic
  RSpec.describe ConnectionsController do
    include_context 'connection'

    let(:mautic_connection) { oauth2 }
    let(:mautic_connections_list) { FactoryBot.create_list(:mautic_connection, 3) }

    it '#index' do
      mautic_connections_list # touch
      get mautic.connections_path
      expect(response).to be_successful
    end

    it '#new' do
      get mautic.new_connection_path
      expect(response).to be_successful
    end

    it '#edit' do
      get mautic.edit_connection_path(mautic_connection)
      expect(response).to be_successful
    end

    it '#show' do
      get mautic.connection_path(mautic_connection)
      expect(response).to be_successful
    end

    context '#create' do
      it 'invalid' do
        expect do
          post mautic.connections_path({ connection: { name: '' } })
        end.to change(Connection, :count).by 0
        expect(response).to be_successful
      end

      it 'valid' do
        expect do
          post(mautic.connections_path({ connection: FactoryBot.attributes_for(:mautic_connection) }))
        end.to change(Connection, :count).by 1
        expect(response).to be_successful
      end
    end

    context '#update' do
      it 'invalid' do
        put mautic.connection_path(mautic_connection, { connection: { url: '' } })
        expect(response).to be_successful
        expect(mautic_connection.reload.url).not_to be_blank
      end

      it 'valid' do
        new_value = "https://#{Faker::Internet.domain_name}"
        put mautic.connection_path(mautic_connection, { connection: { url: new_value } })
        expect(mautic_connection.reload.url).to eq new_value
        expect(response).to have_http_status :redirect
      end
    end

    context 'get access token' do
      let(:oauth2) { FactoryBot.create(:oauth2, url: "https://#{Faker::Internet.unique.domain_name}/sub") }

      it '#authorize' do
        get mautic.authorize_connection_path(oauth2)
        expect(response).to have_http_status :redirect
      end

      it '#oauth2' do
        code = SecureRandom.hex 8
        access_token = SecureRandom.hex 8
        refresh_token = SecureRandom.hex 8
        stub = stub_request(:post, "#{oauth2.url}/oauth/v2/token")
                 .with(body: hash_including({
                                              client_id: oauth2.client_id,
                                              client_secret: oauth2.secret,
                                              code: code,
                                              grant_type: 'authorization_code',
                                            })).to_return(status: 200, body: {
                                              token_type: 'bearer',
                                              access_token: access_token,
                                              refresh_token: refresh_token,
                                              expires_at: Date.tomorrow,
                                            }.to_param, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })

        get mautic.oauth2_connection_path(oauth2, params: { code: code })
        expect(stub).to have_been_requested
      end
    end
  end
end
