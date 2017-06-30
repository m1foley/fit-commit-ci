Rails.application.routes.draw do
  get "/auth/github/callback", to: "sessions#create"
  get "/sign_out", to: "sessions#destroy"
  root to: "home#index"
end
