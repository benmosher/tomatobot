class CommandsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :accept_ssl_checks
  before_action :verify_slack_token
  before_action :check_team
  before_action :check_action
  before_action :find_or_create_user
  after_action :send_notification, if: "ENV[\"NOTIFICATION_URL\"].present?"
  after_action :send_to_amplitude

  def startwork
    return help_response if help_requested?
    return already_active_response if task_active?
    task = Task.create(user: @user, team: @team)
    ActivateDndWorker.perform_async(@user.id) if start_dnd?
    EndTaskWorker.perform_in(unit_duration.minutes, 
                             task.id, 
                             params[:response_url],
                             start_dnd?)
    render json: response_json(started_work_message, response_type)
  end

  def distraction
    return help_response if help_requested?
    return missing_response if params[:text].empty?
    return no_previous if last_task.nil?
    last_task.distraction << params[:text]
    last_task.save
    render json: response_json(t("commands.distraction.saved"), response_type)
  end

  def completed
    return help_response if help_requested?
    return missing_response if params[:text].empty?
    return no_previous if last_task.nil?
    last_task.completed << params[:text]
    last_task.save
    render json: response_json(t("commands.completed.saved"), response_type)
  end

  def review
    return help_response if help_requested?
    return date_parse_failed if beginning_of_review_date.nil?
    @tasks = @user.tasks.
              where("created_at >= ?", beginning_of_review_date).
              where("created_at <= ?", beginning_of_review_date + 1.day)
    render json: response_json(create_list, response_type)
  end

private

  def response_json(text, response_type = "ephemeral")
    {
      response_type: response_type,
      text: text
    }
  end

  def response_type
    return "in_channel" if review_publicly?
    "ephemeral"
  end

  def beginning_of_review_date
    return @beginning_of_review_date if @beginning_of_review_date.present?
    date_variable = params[:text]&.downcase&.gsub("public", "")
    if date_variable.blank?
      return @beginning_of_review_date = Time.zone.now.beginning_of_day
    else
      date = Chronic.parse(date_variable)
      @beginning_of_review_date = date&.beginning_of_day
    end
  end

  def accept_ssl_checks
    render text: "Working" if params[:ssl_check].present? 
  end
  
  def verify_slack_token
    fail "Incorrect token" unless params[:token] == token
  end

  def check_team
    @team = Team.find_by!(slack_team_id: params[:team_id])
  end

  def review_publicly?
    params[:text]&.start_with?("public")
  end

  def task_active?
    return false if last_task.nil?
    last_task.created_at > unit_duration.minutes.ago
  end

  def last_task
    @last_task ||= @user.tasks.last
  end

  def check_action
    fail "Bad action" unless params[:action] == params[:command].delete("/")
  end

  def create_list
    tasks = @tasks.map{ |task| ":tomato: - #{task.completed.to_sentence}" }
    tasks.join("\n")
  end

  def find_or_create_user
    @user = User.find_or_create_by(slack_id: params[:user_id])
    @user.tap { |user| user.update(name: params[:user_name]) }
  end

  def unit_duration
    if Rails.env.production?
      25
    else
      2
    end
  end

  def started_work_message
    [t("commands.startwork.started"), dnd_status_message].join(" ")
  end

  def dnd_status_message
    if start_dnd?
      [
        t("commands.startwork.dnd_started"), 
       "<#{edit_user_url(id: @user.id, key: @user.url_key)}|#{t("settings")}>"
      ].join(". ")
    else
      "<#{edit_user_url(id: @user.id, key: @user.url_key)}|"\
        "#{t("commands.startwork.offer_dnd")}>"
    end
  end

  def no_previous 
    render text: t("commands.#{params[:action]}.no_tasks")
  end

  def missing_response
    render text: t("commands.#{params[:action]}.missing")
  end

  def help_response
    render text: t("commands.#{params[:action]}.help")
  end

  def already_active_response
    end_time = last_task.created_at + unit_duration.minutes
    time_remaining = (end_time - Time.now).round / 60
    render text: t("commands.startwork.already_active", 
                   time:  "#{time_remaining} "\
                          "#{t("time.words.minute").pluralize(time_remaining)}")
  end

  def date_parse_failed 
    render text: t("commands.review.date_parse_failed")
  end

  def help_requested?
    params[:text] == "help"
  end

  def start_dnd?
    @user.dnd_mode && @user.slack_token.present?
  end

  def notification_present?
    ENV["NOTIFICATION_URL"].present?
  end

  def send_notification
    SendNotificationWorker.perform_in(3.seconds, params[:response_url])
  end

  def token
    return "test_token" if Rails.env.test?
    ENV["SLACK_COMMAND_TOKEN"]
  end
  
  def send_to_amplitude
    SendAmplitudeEventWorker.perform_async(@user.slack_id, log_action)
  end

  def log_action
    return "help-#{params[:action]}" if help_requested?
    params[:action]
  end
end
