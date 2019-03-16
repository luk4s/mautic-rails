module Mautic
  RSpec.describe Event do
    include_context 'connection'

    let(:mautic_contact) { Mautic::Contact.new(oauth2, id: 1) }

    before :each do
      stub_request(:get, /#{oauth2.url}\/api\/contacts\/1\/events/)
        .and_return({
                      status: 200,
                      body: file_fixture("events.json").read,
                      headers: { 'Content-Type' => 'application/json' }
                    })
    end
    context "check all types" do
      subject { mautic_contact.events.all }
      # mautic_contact.events.all.each do |event|
      #   it "#attributes #{event.event}" do
      #     expect(event.attributes).to include *%i(created_at contactId event eventId)
      #   end
      #
      #   it "#created_at #{event.event}" do
      #     expect(event.created_at).to be_a Time
      #   end
      #
      #   it "#label #{event.event}" do
      #     expect(event.label).not_to be_blank
      #   end
      #   it "#source_url #{event.event}" do
      #     expect(event.source_url).to match /^http.+\/\w+\/view\/\d+/
      #   end
      # end


      # end
      # end
      it '#attributes' do
        subject.each do |event|
          expect(event.attributes).to include *%i[created_at event eventId]
        end
      end

      it "#created_at" do
        subject.each do |event|
          expect(event.created_at).to be_a Time
        end
      end

      it "#label" do
        subject.each do |event|
          expect { event.label }.not_to raise_error
        end
      end

      it "#source_url" do
        subject.each do |event|
          expect(event.source_url).to match /^http.+\/\w+\/view\/\d+/ if event.source_url
        end
      end
    end
  end
end
