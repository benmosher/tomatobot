Rails.application.routes.draw do
  post 'commands/startwork'
  post 'commands/distraction'
  post 'commands/completed'
  post 'commands/review'

  get "connect", to: "teams#create"

  get "users/:id/:key", to: "users#edit", as: "edit_user"
  get "users/:id/:key/token", to: "users#update_token", as: "update_user_token"
  put "users/:id/:key", to: "users#update", as: "user"
  patch "users/:id/:key", to: "users#update"
  root "teams#new"
end
