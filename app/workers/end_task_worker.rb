class EndTaskWorker
  include Sidekiq::Worker

  def perform(task_id, response_url)
    @task = Task.find(task_id)
    message = [t("workers.end_work.time_up"), 
               completed,
               break_duration, 
               distractions].join(" ")
    SlackNotificationSender.new(response_url).send(message)
  end

private

  def break_duration
    if todays_tasks.count % 4 == 0
      t("workers.end_work.break.twenty")
    else
      t("workers.end_work.break.five")
    end
  end

  def completed
    if @task.completed.empty?
      t("workers.end_work.completed.none")
    else
      t("workers.end_work.completed.list", 
        sentence: @task.completed.to_sentence)
    end
  end

  def distractions
    if @task.distraction.empty?
      t("workers.end_work.distractions.none")
    else
      t("workers.end_work.distractions.list", 
        sentence: @task.distraction.to_sentence)
    end
  end
  
  def todays_tasks
    @task.user.tasks.where("created_at >= ?", Time.zone.now.beginning_of_day)
  end
end
