class SendNotificationWorker 
  include Sidekiq::Worker

  def perform(response_url)
    SlackNotificationSender.new(response_url).send(message)
  end

private

  def message
    HTTParty.get(ENV["NOTIFICATION_URL"])
  end
end
