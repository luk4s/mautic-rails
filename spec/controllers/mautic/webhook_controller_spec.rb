module Mautic
  class FooController < ApplicationController
    include Mautic::ReceiveWebHooks

    def create
      webhook
    end
  end

  describe ApplicationController, type: :controller do
    controller FooController do
      def create
        webhook
        head :ok
      end
    end

    include_context 'connection'
    include_context 'requests'

    it "receive request and find connection" do

      routes.draw { post "webhook/:mautic_connection_id" => "mautic/foo#create" }
      json = JSON.load file_fixture("form_submit_webhook1.json")
      post :create, **params({ mautic_connection_id: oauth2 }.merge(json))

      expect(response).to be_successful
    end
  end
end
