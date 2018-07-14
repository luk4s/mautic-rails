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

      routes.draw { post "webhook/:mautic_id" => "mautic/foo#create" }

      post :create, params({ mautic_id: oauth2 }.merge(JSON.load file_fixture("form_submit_webhook1.json")))

      expect(response).to be_successful
    end
  end
end