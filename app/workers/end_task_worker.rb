class EndTaskWorker
  include Sidekiq::Worker

  def perform(task_id, response_url)
    @task = Task.find(task_id)
    message = ["Time's up.", break_duration, distractions].join(" ")
    SlackNotificationSender.new(response_url).send(message)
  end

private

  def break_duration
    if todays_tasks.count % 4 == 0
      "Take a 20 minute break."
    else
      "Take a 5 minute break."
    end
  end

  def distractions
    if @task.distraction.empty?
      "You didn't tell me about any distractions, well done!"
    else
      "You were distracted by " + @task.distraction.to_sentence + "."
    end
  end
  
  def todays_tasks
    @task.user.tasks.where("created_at >= ?", Time.zone.now.beginning_of_day)
  end
end
