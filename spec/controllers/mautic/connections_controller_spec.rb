require 'rails_helper'

module Mautic
  RSpec.describe ConnectionsController do

    let(:mautic_connection) { FactoryBot.create(:mautic_connection) }
    let(:mautic_connections_list) { FactoryBot.create_list(:mautic_connection, 3) }

    describe "GET #index" do
      it "returns a success response" do
        mautic_connections_list # touch
        get :index, params: { use_route: 'mautic' }
        expect(response).to be_success
      end
    end

    describe "GET #show" do
      it "returns a success response" do
        get :show, params: { use_route: 'mautic', id: mautic_connection.to_param }
        expect(response).to be_success
      end
    end

    describe "GET #new" do
      it "returns a success response" do
        get :new, params: { use_route: 'mautic' }
        expect(response).to be_success
      end
    end

    describe "GET #edit" do
      it "returns a success response" do
        get :edit, params: { use_route: 'mautic', id: mautic_connection.to_param }
        expect(response).to be_success
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new MauticConnection" do
          expect {
            post :create, params: { use_route: 'mautic', connection: FactoryBot.attributes_for(:mautic_connection) }
          }.to change(Connection, :count).by(1)
        end

        it "redirects to the created mautic_connection" do
          post :create, params: { use_route: 'mautic', connection: FactoryBot.attributes_for(:mautic_connection) }
          expect(response).to redirect_to(Connection.last)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { use_route: 'mautic', connection: { url: "xxx" } }
          expect(response).to be_success
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do

        it "updates the requested mautic_connection" do
          put :update, params: { use_route: 'mautic', id: mautic_connection.to_param, connection: { url: "https://newurl.com" } }
          mautic_connection.reload
          expect(mautic_connection.url).to eq 'https://newurl.com'
        end

        it "redirects to the mautic_connection" do
          put :update, params: { use_route: 'mautic', id: mautic_connection.to_param, connection: { url: "https://newurl.com" } }
          expect(response).to redirect_to(mautic_connection)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'edit' template)" do
          put :update, params: { use_route: 'mautic', id: mautic_connection.to_param, connection: { url: "", secret: "" } }
          expect(response).to be_success
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested mautic_connection" do
        mautic_connection # touch
        expect {
          delete :destroy, params: { use_route: 'mautic', id: mautic_connection.to_param }
        }.to change(Connection, :count).by(-1)
      end

      it "redirects to the mautic_connections list" do
        delete :destroy, params: { use_route: 'mautic', id: mautic_connection.to_param }
        expect(response).to have_http_status :redirect
      end
    end

  end
end
