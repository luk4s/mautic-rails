RSpec.describe Mautic::Submissions::Form do
  include_context 'connection'

  let(:data) do
    data = JSON.load(file_fixture("form_submit_webhook1.json"))
    data["mautic.form_on_submit"]["submission"]
  end
  subject { described_class.new(oauth2, data.with_indifferent_access) }

  it '#form_id' do
    expect(subject.form_id).to eq 4
  end

  it '#contact_id' do
    expect(subject.contact_id).to eq 26
  end

  it '#form' do
    expect(frm = subject.form).to be_a Mautic::Form
    expect(frm.fields).to include({ "email" => "email@formsubmit.com" })
  end

  it '#contact' do
    expect(c = subject.contact).to be_a Mautic::Contact
    expect(c.email).to eq "email@formsubmit.com"
  end

  it '#referer' do
    expect(subject.referer).to eq "http://mautic-gh.com/index_dev.php/s/forms/preview/4"
  end

end
