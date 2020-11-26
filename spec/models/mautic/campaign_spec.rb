module Mautic
  RSpec.describe Campaign do
    include_context 'connection'
    include_context 'contact'

    let(:entity) { described_class.new oauth2, id: 1, name: "Test campaign" }

    it "get single campaign" do
      stub = stub_request(:get, "#{oauth2.url}/api/campaigns/3").
        to_return(status: 200,
                  body: file_fixture("campaign.json").read,
                  headers: { 'Content-Type' => 'application/json' }
        )
      campaign = described_class.in(oauth2).find 3
      expect(stub).to have_been_made
      expect(campaign.name).to eq "Email A/B Test"
    end

    describe "#add_contact!" do
      subject { entity.add_contact!(3) }
      it "success" do
        stub = stub_request(:post, "#{oauth2.url}/api/campaigns/1/contact/3/add").
          to_return(status: 200,
                    body: { success: true }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
          )
        is_expected.to eq true
        expect(stub).to have_been_made
      end

      it "handle error" do
        stub = stub_request(:post, "#{oauth2.url}/api/campaigns/1/contact/3/add").
          to_return(status: 404,
                    body: { success: false }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
          )
        is_expected.to eq false
        expect(stub).to have_been_made
      end
    end

    describe "#remove_contact!" do
      subject { entity.remove_contact!(3) }
      it "success" do
        stub = stub_request(:post, "#{oauth2.url}/api/campaigns/1/contact/3/remove").
          to_return(status: 200,
                    body: { success: true }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
          )
        is_expected.to eq true
        expect(stub).to have_been_made
      end
      it "handle error" do
        stub = stub_request(:post, "#{oauth2.url}/api/campaigns/1/contact/3/remove").
          to_return(status: 404,
                    body: { success: false }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
          )
        is_expected.to eq false
        expect(stub).to have_been_made
      end
    end
  end
end