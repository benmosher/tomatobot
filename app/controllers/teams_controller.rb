class TeamsController < ApplicationController
  def new
  end

  def create
    if params[:code].present?
      @team = Team.find_or_create_by(slack_team_id: exchanged_token[:team_id])
      @team.update(team_params)
    else
      redirect_to root_path, alert: t("teams.create.no_code")
    end
  end

private
  
  def exchanged_token
    @exchanged_token ||= SlackTokenExchanger.
                         new(params[:code]).
                         exchange.
                         symbolize_keys
  end

  def team_params
    {
      slack_team_id: exchanged_token[:team_id],
      access_token: exchanged_token[:access_token]
    }
  end
end
