require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "creating a new user" do
    omniauth_hash = OmniAuth::AuthHash.new(
      "info" => { "nickname" => "ghname" },
      "credentials" => { "token" => "ghtoken" }
    )

    assert_difference("User.count", 1) do
      post sessions_url, env: { "omniauth.auth" => omniauth_hash }
      assert_response :success
    end
    user = User.order(:created_at).last
    assert_equal "ghname", user.username
    assert_equal "ghtoken", user.github_token
    assert user.remember_token.present?
    assert_equal session[:remember_token], user.remember_token
  end

  test "logging in an existing user" do
    user = users(:alice)
    omniauth_hash = OmniAuth::AuthHash.new(
      "info" => { "nickname" => user.username },
      "credentials" => { "token" => "new_ghtoken" }
    )

    assert_no_difference("User.count") do
      post sessions_url, env: { "omniauth.auth" => omniauth_hash }
      assert_response :success
    end
    user.reload
    assert_equal "new_ghtoken", user.github_token
    assert_equal session[:remember_token], user.remember_token
  end
end
