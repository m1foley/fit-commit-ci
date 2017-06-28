Rails.application.routes.draw do
  resources :sessions, only: [:create]
  get "/auth/github/callback", to: "sessions#create"
  root to: "home#index"
end
