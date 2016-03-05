Rails.application.routes.draw do
  post 'commands/startwork'
  post 'commands/distraction'
  post 'commands/completed'
  post 'commands/review'

  get "connect", to: "teams#create"
  root "teams#new"
end
