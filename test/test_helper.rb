require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "webmock/minitest"

class ActiveSupport::TestCase
  fixtures :all
  OmniAuth.config.test_mode = true
end

class ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.mock_auth[:github] = nil
  end

  def sign_in_as(user)
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      "info" => { "nickname" => user.username },
      "credentials" => { "token" => "ghtoken" }
    )
    get auth_github_callback_url
  end
end
