require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "mocha/mini_test"
require "webmock/minitest"
require_relative "helpers/github_api_helper"

class ActiveSupport::TestCase
  fixtures :all
  OmniAuth.config.test_mode = true
  include GithubApiHelper
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
