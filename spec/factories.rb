FactoryGirl.define do
  factory :team do
    slack_team_id { Faker::Internet.password(5) }
    access_token { Faker::Internet.password(25) }
  end
end
