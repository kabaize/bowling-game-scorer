Rails.application.routes.draw do
  post "/score", to: "scores#create"
end
