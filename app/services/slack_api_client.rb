class SlackApiClient 
  include HTTParty
  base_uri 'https://slack.com/api'

  def initialize
  end

  def oauth_access(query = {}, options = {})
    query[:client_id] = ENV["SLACK_CLIENT_ID"] 
    query[:client_secret] = ENV["SLACK_CLIENT_SECRET"] 
    query[:redirect_uri] = Rails.application.routes.url_helpers.connect_url 
    options[:body] = query
    self.class.post('/oauth.access', options)
  end
end
