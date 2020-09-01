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

    describe Tag::Collection do
      let(:model) { Model.new(oauth2) }
      let(:tags) { [Tag.new(model, { tag: "tag1" }), Tag.new(model, { tag: "tag2" })] }
      subject { described_class.new model, *tags }
      describe "<<" do
        context "trigger model changed?" do
          it "string" do
            expect { subject << "cipisek" }.to change(model, :changed?).to true
          end
          it "Tag instance" do
            expect {
              subject << Tag.new(model, { tag: "cipisek" })
            }.to change(model, :changed?).to true
          end
        end
      end

      describe "#to_mautic" do
        it "should be array" do
          expect(subject.to_mautic).to eq %w[tag1 tag2]
        end
      end

      describe "#remove" do
        it "delete tag" do
          expect { subject.remove("tag1") }.to change(subject, :size).from(2).to 1
        end
        it "#to_mautic include -tag1" do
          expect { subject.remove("tag1") }.to change(subject, :to_mautic).to %w[tag2 -tag1]
        end

        it "trigger model changed?" do
          expect { subject.remove("tag1") }.to change(model, :changed?).to true
        end
      end
    end
  end
end
