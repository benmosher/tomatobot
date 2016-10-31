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

  before :each do
    allow(EndTaskWorker).to receive(:perform_in)
  end

  describe "GET #start" do
    before :each do
      Task.delete_all
    end

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

    it "fails if a task is part-way through" do
      post :startwork, start_attributes
      Timecop.travel(Time.now + 1.minute) do
        post :startwork, start_attributes
        expect(response.body).to include("part way through")
      end
    end

    it "shows how long is left" do
      post :startwork, start_attributes
      Timecop.travel(Time.now + 1.minute) do
        post :startwork, start_attributes
        expect(response.body).to include("1 minute remaining")
      end
    end

    it "shows how long is left to the next whole minute" do
      post :startwork, start_attributes
      Timecop.travel(Time.now + 10.seconds) do
        post :startwork, start_attributes
        expect(response.body).to include("1 minute remaining")
      end
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
    before :each do
      { 3 => DateTime.now, 
        4 => 1.day.ago, 
        5 => "2016-02-03 12:46"}.each do |count, date|
        FactoryGirl.create_list(:task, count.to_i, created_at: date, user: user)
      end
    end

    context "with no date set" do
      let :review_attributes do
        call_attributes.merge(command: "/review")
      end

      it "returns http success" do
        get :review, review_attributes
        expect(response).to have_http_status(:success)
      end

      it "returns the correct number of items" do
        get :review, review_attributes
        expect(assigns(:tasks).size).to eq(3)
      end
    end

    context "with yesterday set" do
      let :yesterday_review_attributes do
        call_attributes.merge(command: "/review", text: "yesterday")
      end

      it "returns http success" do
        get :review, yesterday_review_attributes
        expect(response).to have_http_status(:success)
      end

      it "returns the correct number of items" do
        get :review, yesterday_review_attributes
        expect(assigns(:tasks).size).to eq(4)
      end
    end

    context "with a specific date set" do
      let :custom_review_attributes do
        call_attributes.merge(command: "/review", text: "3 Feb 2016")
      end

      it "returns http success" do
        get :review, custom_review_attributes
        expect(response).to have_http_status(:success)
      end

      it "returns the correct number of items" do
        get :review, custom_review_attributes
        expect(assigns(:tasks).size).to eq(5)
      end
    end

    context "with a date that could be a range" do
      let :range_review_attributes do
        call_attributes.merge(command: "/review", text: "last week")
      end

      it "returns http success" do
        get :review, range_review_attributes
        expect(response).to have_http_status(:success)
      end

      it "returns the correct number of items" do
        get :review, range_review_attributes
        expect(assigns(:tasks).size).to eq(0)
      end
    end
  end

end
