Rails.application.routes.draw do
  get "/auth/github/callback", to: "sessions#create"
  get "/sign_out", to: "sessions#destroy"
  resources :repos, only: [:index] do
    resource :activation, only: [:create]
  end
  resources :builds, only: [:create, :index]
  root to: "home#index"
end
