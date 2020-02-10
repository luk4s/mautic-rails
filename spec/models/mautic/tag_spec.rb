module Mautic
  RSpec.describe Tag do
    include_context 'connection'
    include_context 'tag'
    context 'with instance' do

      subject do
        _stub = stub_request(:get, "#{oauth2.url}/api/tags/1")
                  .and_return({
                                status: 200,
                                body: tag_json,
                                headers: { 'Content-Type' => 'application/json' }
                              })
        described_class.in(oauth2).find(1)
      end

      it '#name' do
        expect(subject.name).to eq "tagA"
      end

      it '#name=' do
        expect(subject.name).to eq "tagA"
        subject.name = "XX"
        expect(subject.name).to eq "XX"
      end
    end
  end
end
