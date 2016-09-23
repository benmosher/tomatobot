class SendAmplitudeEventWorker 
  attr_accessor :user_id, :event_type
  AMPLITUDE_URL = "https://api.amplitude.com/httpapi"
  include Sidekiq::Worker

  def perform(user_id, event_type)
    @user_id = user_id
    @event_type = event_type
    HTTParty.post(AMPLITUDE_URL, body: payload)
  end

private

  def payload
    {
      api_key: ENV["AMPLITUDE_KEY"],
      event: event.to_json
    }
  end

  def event
    {
      user_id: user_id,
      event_type: event_type
    }
  end
end
