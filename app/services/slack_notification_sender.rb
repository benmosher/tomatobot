class SlackNotificationSender
  def initialize(response_url)
    @response_url = response_url 
  end

  def send(text) 
    body = { text: text }.to_json
    HTTParty.post(@response_url, body: body)
  end
end
