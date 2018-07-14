RSpec.describe Mautic::WebHook do
  include_context 'connection'

  let(:data) { ActionController::Parameters.new(JSON.load(file_fixture("form_submit_webhook1.json"))) }
  subject { described_class.new(oauth2, data) }

  describe "Form Submit Event" do
    it '#form_submissions' do
      expect(subject.form_submissions).to be_a Array
    end
  end
end