require "test_helper"

class ActiveModelErrorsTest < ActiveSupport::TestCase
  def test_create_hook_error
    token = "theghtoken"
    full_repo_name = "foo/bar"
    callback_endpoint = "https://foo.com/baz"

    stub_request(:post, "https://api.github.com/repos/foo/bar/hooks").
      with(
        body: %({"name":"web","config":{"url":"#{callback_endpoint}"},"events":["pull_request"],"active":true}),
        headers: { "Authorization" => "token #{token}" }).
      to_return(status: 400, body: "The error msg")

    assert_raise(Octokit::Error, "The error msg") do
      GithubApi.new(token).create_hook(full_repo_name, callback_endpoint)
    end
  end

  def test_create_hook_already_exists
    token = "theghtoken"
    full_repo_name = "foo/bar"
    callback_endpoint = "https://foo.com/baz"

    stub_request(:post, "https://api.github.com/repos/foo/bar/hooks").
      with(
        body: %({"name":"web","config":{"url":"#{callback_endpoint}"},"events":["pull_request"],"active":true}),
        headers: { "Authorization" => "token #{token}" }).
      to_return(status: 422, body: "Hook already exists")

    assert_raise(GithubApi::HookAlreadyExists, "Hook already exists") do
      GithubApi.new(token).create_hook(full_repo_name, callback_endpoint)
    end
  end

  def test_create_hook_success
    token = "theghtoken"
    full_repo_name = "foo/bar"
    callback_endpoint = "https://foo.com/baz"

    stub_request(:post, "https://api.github.com/repos/foo/bar/hooks").
      with(
        body: %({"name":"web","config":{"url":"#{callback_endpoint}"},"events":["pull_request"],"active":true}),
        headers: { "Authorization" => "token #{token}" }).
      to_return(
        status: 201,
        body: "{\"id\":132}",
        headers: { "Content-Type" => "application/json; charset=utf-8" }
      )

    hook = GithubApi.new(token).create_hook(full_repo_name, callback_endpoint)
    assert_equal 132, hook.id
  end
end
