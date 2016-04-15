class TeamsController < ApplicationController
  def new
  end

  def create
    if params[:code].present?
      return notify_error if exchanged_token[:ok] == false
      @team = Team.
        find_or_initialize_by(slack_team_id: exchanged_token[:team_id])
      @team.access_token = exchanged_token[:access_token]
      @team.save
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

  def notify_error
    logger.warn "Token exchange failed for token: #{@exchanged_token}"
    redirect_to root_path, alert: t("teams.create.exchange_failed")
  end
end
