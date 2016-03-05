Rails.application.routes.draw do
  get "connect", to: "teams#create"
  root "teams#new"
end
