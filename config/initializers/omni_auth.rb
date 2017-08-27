Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
    Rails.application.secrets.fetch(:github_key),
    Rails.application.secrets.fetch(:github_secret),
    scope: "public_repo"
end
