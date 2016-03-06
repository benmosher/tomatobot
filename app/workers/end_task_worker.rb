class EndTaskWorker
  include Sidekiq::Worker

  def perform(task, response_url)
    SlackNotificationSender.new(response_url).send("Time's up")
  end
end
