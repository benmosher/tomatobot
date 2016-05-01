require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(FactoryGirl.build(:user)).to be_valid
  end

  it "is invalid without a name" do
    expect(FactoryGirl.build(:user, name: nil)).not_to be_valid
  end

  it "is invalid without a Slack ID" do
    expect(FactoryGirl.build(:user, slack_id: nil)).not_to be_valid
  end

  context "has a url_key which" do
    it "gets a token after being saved" do
      user = FactoryGirl.create(:user)
      expect(user.url_key).to be_present
    end
    it "gets replaced on a further save" do
      user = FactoryGirl.create(:user)
      old_token = user.url_key
      user.update(name: "Example")
      expect(user.url_key).not_to eq(old_token) 
    end
  end

  context "has a slack_token which" do
    it "when blank, prevents DND switching on" do
      user = FactoryGirl.create(:user)
      expect(user.dnd_mode).to be false
      expect(user.slack_token).to be_nil
      user.dnd_mode = true
      expect(user).not_to be_valid
    end
  end
end
