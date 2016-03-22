class EndTaskWorker
  include ApplicationHelper
  include Sidekiq::Worker

  def perform(task_id, response_url)
    @task = Task.find(task_id)
    message = [I18n.t("workers.end_work.time_up"), 
               completed,
               distractions,
               break_duration].join(" ")
    SlackNotificationSender.new(response_url).send(message)
  end

private

  def break_duration
    if todays_tasks.count % 4 == 0
      I18n.t("workers.end_work.break.twenty")
    else
      I18n.t("workers.end_work.break.five")
    end
  end

  def completed
    if @task.completed.empty?
      I18n.t("workers.end_work.completed.none")
    else
      I18n.t("workers.end_work.completed.list", 
             sentence: bold_list(@task.completed).to_sentence)
    end
  end

  def distractions
    if @task.distraction.empty?
      I18n.t("workers.end_work.distractions.none")
    else
      I18n.t("workers.end_work.distractions.list", 
             sentence: bold_list(@task.distraction).to_sentence)
    end
  end
  
  def todays_tasks
    @task.user.tasks.where("created_at >= ?", Time.zone.now.beginning_of_day)
  end
end
