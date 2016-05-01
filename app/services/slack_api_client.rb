class SlackApiClient 
  include HTTParty
  base_uri 'https://slack.com/api'

  def initialize
  end

  def oauth_access(query = {}, options = {})
    query[:client_id] = ENV["SLACK_CLIENT_ID"] 
    query[:client_secret] = ENV["SLACK_CLIENT_SECRET"] 
    query[:redirect_uri] ||= redirect_url 
    options[:body] = query
    self.class.post('/oauth.access', options.except(:redirect_uri))
  end

  def start_dnd(query = {}, options = {})
    options[:body] = query
    self.class.post("/dnd.setSnooze", options)
  end

  def end_dnd(query = {}, options = {})
    options[:body] = query
    self.class.post("/dnd.endSnooze", options)
  end

private

  def redirect_url
    if Rails.env.development?
      Rails.application.routes.url_helpers.connect_url
    else
      Rails.application.routes.url_helpers.connect_url(protocol: "https")
    end
  end
end
