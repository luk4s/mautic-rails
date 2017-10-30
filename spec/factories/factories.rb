FactoryBot.define do
  factory :mautic_connection, class: 'Mautic::Connection' do
    url { 'https://' + Faker::Internet.unique.domain_name }
    client_id { Faker::Internet.password }
    secret { Faker::Internet.password }

    factory :oauth2, class: 'Mautic::Connections::Oauth2' do
      type 'Mautic::Connections::Oauth2'
    end
  end
end

