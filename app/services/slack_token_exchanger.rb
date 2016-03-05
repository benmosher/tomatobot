class SlackTokenExchanger
  attr_accessor :code

  def initialize(code)
    @code = code
  end

  def exchange
    slack_client.oauth_access(code: @code)
  end

private

  def slack_client
    @slack_client ||= SlackApiClient.new
  end
end
