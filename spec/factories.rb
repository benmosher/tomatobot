FactoryGirl.define do
  factory :user do
    slack_id { Faker::Internet.password(5) }
    name { Faker::Internet.user_name }
  end

  factory :team do
    slack_team_id { Faker::Internet.password(5) }
    access_token { Faker::Internet.password(25) }
  end
end
