RSpec.shared_context "mautic fields" do |name|
  include_context 'connection'

  it "get field" do
    stub_request(:get, "#{oauth2.url}/api/fields/#{name}/165")

    field = described_class.in(oauth2).find 165
    expect(field).to be_a described_class
  end
end
RSpec.describe Mautic::ContactField do
  include_context 'mautic fields', "contact"
end
RSpec.describe Mautic::CompanyField do
  include_context 'mautic fields', "company"
end
