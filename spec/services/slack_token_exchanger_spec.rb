require 'rails_helper'
RSpec.describe SlackTokenExchanger, type: :service do
  let :code_response do
    { 
      ok: true,
      access_token: "response_access_token",
      scope: "identify,commands",
      team_name: "Matthew's Example Team",
      team_id: "team_id"
    }
  end

  let :slack_client do
    double(SlackApiClient)
  end

  describe "exchange" do
    before :each do
      expect(SlackApiClient).to receive(:new){ slack_client }
      expect(slack_client).to receive(:oauth_access).
        with({
              code: "12345-code-here-4567"
             }
            ){ code_response }
    end

    it "exchange" do
      token_hash = described_class.new("12345-code-here-4567").exchange
      expect(token_hash[:access_token]).to eq("response_access_token")
      expect(token_hash[:team_id]).to eq("team_id")
    end
  end
end
