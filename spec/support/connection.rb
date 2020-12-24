RSpec.shared_context "connection", shared_context: :metadata do

  let(:oauth2) { FactoryBot.create(:oauth2, token: Faker::Internet.password, refresh_token: Faker::Internet.password) }
  let(:responses) do
    {
      404 => { "errors" => [{ "code" => 404, "message" => "Item was not found.", "details" => [] }] }.to_json
    }
  end
end
