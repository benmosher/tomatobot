require 'rails_helper'
RSpec.describe UsersController, type: :controller do
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

  let :user do
    FactoryGirl.create(:user)
  end

  describe "access control" do
    it "fails with an incorrect URL key" do
      expect{ get :edit, id: user.id, key: "wrong_key"}.
        to raise_error(ActionController::RoutingError)
    end

    it "passes with a valid URL key" do
      expect{ get :edit, id: user.id, key: user.url_key }.
        not_to raise_error
    end
  end

  describe "GET #edit" do
    it "loads a user" do
      get :edit, id: user.id, key: user.url_key
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "GET #update_token" do
    context "with no code" do
      it "redirects to edit" do
        get :update_token, id: user.id, key: user.url_key
        expect(response).
          to redirect_to(edit_user_url(id: user.id, key: user.url_key))
      end
    end

    context "with an invalid code" do
      it "redirects to root" do
        expect(SlackTokenExchanger).to receive(:new).with("WRONGCODE"){ exchanger }
        expect(exchanger).to receive(:exchange){ faulty_exchanged_data }
        get :update_token, id: user.id, key: user.url_key, code: "WRONGCODE"
        expect(response).
          to redirect_to(edit_user_url(id: user.id, key: user.url_key))
        expect(user.slack_token).to be_nil
      end
    end

    context "with a valid code" do
      it "exchanges the code" do
        expect(SlackTokenExchanger).to receive(:new).with("MYCODE"){ exchanger }
        expect(exchanger).to receive(:exchange){ exchanged_data }
        get :update_token, id: user.id, key: user.url_key, code: "MYCODE"
        user.reload
        expect(user.slack_token).to eq("completed-access-token")
      end
    end
  end
end
