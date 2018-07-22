RSpec.shared_context "tag", shared_context: :metadata do
  let(:tag_json) { file_fixture("tag.json").read }
  let(:tags_json) { file_fixture("tags.json").read }
  let(:tag) { JSON.parse(tag_json) }
end