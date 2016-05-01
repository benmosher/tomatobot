class ActivateDndWorker 
  include ApplicationHelper
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    raise "User did not request DND" if user.dnd_mode == false
    raise "Missing personal token" if user.slack_token.nil?
    client.start_dnd(token: user.slack_token, num_minutes: 27)
  end

private

  def client
    @client ||= SlackApiClient.new
  end
end
