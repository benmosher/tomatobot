require 'rails_helper'
RSpec.describe Task, type: :model do
  it "has a valid spec" do
    expect(FactoryGirl.build(:task)).to be_valid
  end

  it "is invalid without a team" do
    expect(FactoryGirl.build(:task, team: nil)).not_to be_valid
  end

  it "is invalid without a user" do
    expect(FactoryGirl.build(:task, user: nil)).not_to be_valid
  end

  it "is valid without a completed task" do
    expect(FactoryGirl.build(:task, completed: nil)).to be_valid
  end

  it "is valid with multiple completed tasks" do
    expect(FactoryGirl.build(:task, completed: ["task one", "task two"])).
      to be_valid
  end

  it "is valid without a distraction" do
    expect(FactoryGirl.build(:task, completed: nil)).to be_valid
  end

  it "is valid with multiple distractions" do
    expect(FactoryGirl.build(:task, completed: ["thing one", "thing two"])).
      to be_valid
  end
end
