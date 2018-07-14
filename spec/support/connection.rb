RSpec.shared_context "connection", shared_context: :metadata do

  let(:oauth2) { FactoryBot.create(:oauth2, token: Faker::Internet.password, refresh_token: Faker::Internet.password) }

end