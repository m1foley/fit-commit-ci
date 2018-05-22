ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
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

  def assert_turbolinks_redirect(url)
    assert_equal "text/javascript", @response.content_type
    assert_match(/Turbolinks\.visit\("#{url}", {"action":"replace"}\)/, @response.body)
  end
end
