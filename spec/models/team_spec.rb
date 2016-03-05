require 'rails_helper'
RSpec.describe Team, type: :model do
  it "has a valid factory" do
    expect(FactoryGirl.build(:team)).to be_valid
  end

  it "is invalid without a team id" do
    expect(FactoryGirl.build(:team, slack_team_id: nil)).not_to be_valid
  end

  it "is invalid without an access token" do
    expect(FactoryGirl.build(:team, access_token: nil)).not_to be_valid
  end
end
