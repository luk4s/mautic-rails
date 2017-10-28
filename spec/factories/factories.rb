FactoryBot.define do
  factory :mautic_connection, class: 'Mautic::MauticConnection' do
    url { 'https://' + Faker::Internet.unique.domain_name }
    client_id { Faker::Internet.password }
    secret { Faker::Internet.password }

    trait :oauth2 do
      type 'Mautic::Connections::Oauth2'
    end
  end
end

