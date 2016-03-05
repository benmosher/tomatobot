class CommandsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_slack_token
  before_action :check_team
  before_action :check_action

  def startwork
    return help_response if help_requested?
    render text: t("commands.startwork.started")
  end

  def distraction
    return help_response if help_requested?
    return missing_response if params[:text].empty?
    render text: t("commands.distraction.saved")
  end

  def completed
    return help_response if help_requested?
    return missing_response if params[:text].empty?
    render text: t("commands.completed.saved")
  end

  def review
    return help_response if help_requested?
    render text: "One thing. Another. Another."
  end

private

  def verify_slack_token
    fail "Incorrect token" unless params[:token] == token
  end

  def check_team
    @team = Team.find_by!(slack_team_id: params[:team_id])
  end

  def check_action
    fail "Bad action" unless params[:action] == params[:command].delete("/")
  end

  def missing_response
    render text: t("commands.#{params[:action]}.missing")
  end

  def help_response
    render text: t("commands.#{params[:action]}.help")
  end

  def help_requested?
    params[:text] == "help"
  end

  def token
    return "test_token" if Rails.env.test?
    ENV["SLACK_COMMAND_TOKEN"]
  end
end
