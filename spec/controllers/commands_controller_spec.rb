require 'rails_helper'
RSpec.describe CommandsController, type: :controller do
  let :team do
    FactoryGirl.create(:team)
  end

  let :user do
    FactoryGirl.create(:user)
  end

  let :call_attributes do
    {
      token: "test_token",
      team_id: team.slack_team_id,
      team_domain: "example",
      channel_id: "channel1",
      channel_name: "general",
      user_id: user.slack_id,
      user_name: user.name,
      response_url: "https://hooks.slack.com/commands/989779"
    }
  end

  describe "GET #start" do
    let :start_attributes do
      call_attributes.merge(command: "/startwork")
    end

    it "refuses to respond if the authentication code is correct" do
      expect{ post :startwork, start_attributes.merge(token: "incorrect") }.
        to raise_exception("Incorrect token")
    end

    it "refuses to respond if the team is in the database" do
      expect{ post :startwork, start_attributes.merge(team_id: "000000") }.
        to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "refuses to respond if the command is not start" do
      expect{ post :startwork, start_attributes.merge(command: "/notstart") }.
        to raise_exception("Bad action")
    end

    it "responds to a request for help properly" do
      post :startwork, start_attributes.merge(text: "help")
      expect(response).to have_http_status(:success)
    end

    it "returns http success" do
      post :startwork, start_attributes
      expect(response).to have_http_status(:success)
    end
    
    it "loads the correct user" do
      post :startwork, start_attributes
      expect(assigns(:user)).to eq(user)
    end

    it "creates the user if they don't exist" do
      post :startwork, start_attributes.merge(user_id: "NEWUSERID", user_name: "Sam")
      expect(assigns(:user).slack_id).to eq("NEWUSERID")
      expect(assigns(:user).name).to eq("Sam")
    end
  end

  describe "GET #distraction" do
    let :distract_attributes do
      call_attributes.merge(command: "/distraction", text: "Call Jaakko back")
    end

    it "re-prompts with no input" do
      expect{ post :distraction, distract_attributes.merge(text: "") }.
        not_to raise_error 
    end
    
    it "returns http success" do
      post :distraction, distract_attributes
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #completed" do
    let :completed_attributes do
      call_attributes.merge(command: "/completed", text: "Fix payments bug")
    end

    it "returns http success" do
      get :completed, completed_attributes
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #review" do
    let :review_attributes do
      call_attributes.merge(command: "/review")
    end

    it "returns http success" do
      get :review, review_attributes
      expect(response).to have_http_status(:success)
    end
  end

end
