module Mautic
  class FooController < ApplicationController
    include Mautic::ReceiveWebHooks
  end
  describe ApplicationController, type: :controller do
    controller FooController do

    end

    let(:oauth2) { FactoryBot.create(:oauth2) }

    it "receive request and find connection" do

      routes.draw { post "webhook/:mautic_id" => "mautic/foo#webhook" }

      post :webhook, params: { mautic_id: oauth2 }.merge(JSON.load file_fixture("form_submit_wabhook1.json"))

      expect(response).to be_successful
    end
  end
end