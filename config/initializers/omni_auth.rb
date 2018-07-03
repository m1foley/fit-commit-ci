Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
    Rails.application.credentials.github[:key],
    Rails.application.credentials.github[:secret],
    scope: "public_repo"
end
