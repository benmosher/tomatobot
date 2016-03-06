require 'rails_helper'
RSpec.describe SlackNotificationSender, type: :service do
  let :response_url do
    "https://hooks.slack.com/commands/T0QHRHP4P/24713001589/"\
      "bukgKdlULI8iBQNLDra97E51"
  end

  let :message_text do
    "Message goes here"
  end

  describe "send" do
    it "sends the message over HTTP" do
      message_body = { text: message_text }.to_json
      expect(HTTParty).to receive(:post).
        with(response_url, body: message_body){ "ok" }
      described_class.new(response_url).send(message_text)
    end
  end
end
