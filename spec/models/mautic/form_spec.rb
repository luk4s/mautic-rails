module Mautic
  RSpec.describe Form do
    include_context 'connection'

    let(:entity) { described_class.new oauth2, JSON.load(file_fixture("form.json"))["form"] }

    it "get single form" do
      stub = stub_request(:get, "#{oauth2.url}/api/forms/3").
        to_return(status: 200,
                  body: file_fixture("form.json").read,
                  headers: { 'Content-Type' => 'application/json' }
        )
      entity = described_class.in(oauth2).find 3
      expect(stub).to have_been_made
      expect(entity.name).to eq "Newlsetter"
    end

    describe "#submission" do
      subject { entity.submission(1) }

      it "not found" do
        stub_request(:get, "#{oauth2.url}/api/forms/3/submissions/1").to_return(status: 404, body: responses[404])
        expect(subject).to be_nil
      end
      it "submission object" do
        stub_request(:get, "#{oauth2.url}/api/forms/3/submissions/1").to_return(status: 200, body: file_fixture("submission.json"))
        expect(subject).to be_a Mautic::Submissions::Form
      end
    end
    describe "#submissions" do
      subject { entity.submissions }
      it "empty array" do
        stub_request(:get, "#{oauth2.url}/api/forms/3/submissions").to_return(status: 200, body: { submissions: [] }.to_json)
        expect(subject).to be_empty
      end
      it "submissions data" do
        stub_request(:get, "#{oauth2.url}/api/forms/3/submissions").to_return(status: 200, body: { submissions: [{id: 1, results: [] }] }.to_json)
        expect(subject).to include be_a(Mautic::Submissions::Form)
      end
      it "not found" do
        stub_request(:get, "#{oauth2.url}/api/forms/3/submissions").to_return(status: 404, body: responses[404])
        expect(subject).to be_empty
      end
    end
  end
end
