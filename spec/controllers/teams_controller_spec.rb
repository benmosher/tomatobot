require 'rails_helper'
RSpec.describe TeamsController, type: :controller do
  let :exchanger do
    double(SlackTokenExchanger)
  end

  let :exchanged_data do
    {
      ok: true,
      access_token: "completed-access-token",
      scope: "identify,commands",
      team_name: "Example Team",
      team_id: "ABCDEFG"
    }.stringify_keys
  end
  
  let :faulty_exchanged_data do
    {
      ok: false,
    }.stringify_keys
  end

  describe "GET #create" do
    context "with no code" do
      it "redirects to root" do
        get :create
        expect(response).to redirect_to(root_url)
      end
    end

    context "with an invalid code" do
      it "redirects to root" do
        expect(SlackTokenExchanger).to receive(:new).with("WRONGCODE"){ exchanger }
        expect(exchanger).to receive(:exchange){ faulty_exchanged_data }
        get :create, code: "WRONGCODE"
        expect(response).to redirect_to(root_url)
        expect(Team.first).to be_nil
      end
    end

    context "with a valid code" do
      it "exchanges the code" do
        expect(SlackTokenExchanger).to receive(:new).with("MYCODE"){ exchanger }
        expect(exchanger).to receive(:exchange){ exchanged_data }
        get :create, code: "MYCODE"
        new_team = Team.last
        expect(new_team.access_token).to eq("completed-access-token")
        expect(new_team.slack_team_id).to eq("ABCDEFG")
      end
    end
  end

  describe "GET #create" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

end
