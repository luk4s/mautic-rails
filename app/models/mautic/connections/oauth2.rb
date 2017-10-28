module Mautic
  module Connections
    class Oauth2 < Mautic::MauticConnection

      def client
        @client ||= OAuth2::Client.new(client_id, secret, {
          site: url,
          authorize_url: '/oauth/v2/authorize',
          token_url: '/oauth/v2/token'
        })
      end

      def authorize
        client.auth_code.authorize_url(redirect_uri: callback_url)
      end

      def get_code(code)
        client.auth_code.get_token(code, redirect_uri: callback_url)
      end

      def connection
        @connection ||= OAuth2::AccessToken.new(client, token, { refresh_token: refresh_token })
      end

      private

      def callback_url
        uri = URI.parse(Mautic.config.base_url)
        uri.path = Mautic::Engine.routes.url_helpers.oauth2_mautic_connection_path(self)
        uri.to_s
      end

    end
  end
end