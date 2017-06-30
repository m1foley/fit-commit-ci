require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  teardown do
    OmniAuth.config.mock_auth[:github] = nil
  end

  test "invalid credentials" do
    skip("Implement /auth/failure?message=invalid_credentials")
    OmniAuth.config.mock_auth[:github] = :invalid_credentials
    get auth_github_callback_url
    assert_redirected_to auth_failure_path
  end

  test "creating a new user" do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      "info" => { "nickname" => "ghname" },
      "credentials" => { "token" => "ghtoken" }
    )

    assert_difference("User.count", 1) do
      get auth_github_callback_url
      assert_redirected_to root_path
    end
    user = User.order(:created_at).last
    assert_equal "ghname", user.username
    assert_equal "ghtoken", user.github_token
    assert user.remember_token.present?
    assert_equal session[:remember_token], user.remember_token
    OmniAuth.config.mock_auth[:github] = nil
  end

  test "logging in an existing user" do
    user = users(:alice)
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      "info" => { "nickname" => user.username },
      "credentials" => { "token" => "new_ghtoken" }
    )

    assert_no_difference("User.count") do
      get auth_github_callback_url
      assert_redirected_to root_path
    end
    user.reload
    assert_equal "new_ghtoken", user.github_token
    assert_equal session[:remember_token], user.remember_token
  end

  def sign_in_as(user)
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      "info" => { "nickname" => user.username },
      "credentials" => { "token" => "ghtoken" }
    )
    get auth_github_callback_url
  end

  test "logging out" do
    sign_in_as(users(:alice))
    assert session[:remember_token].present?
    get sign_out_url
    assert_redirected_to root_path
    assert_nil session[:remember_token]
  end
end
