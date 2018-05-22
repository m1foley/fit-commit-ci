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

  def test_remove_hook_error
    token = "theghtoken"
    repo = repos(:brian_active_repo)

    stub_request(:delete, "https://api.github.com/repos/#{repo.name}/hooks/#{repo.hook_id}").
      with(headers: { "Authorization" => "token #{token}" }).
      to_return(status: 400, body: "The error msg")

    assert_raise(Octokit::Error, "The error msg") do
      GithubApi.new(token).remove_hook(repo.name, repo.hook_id)
    end
  end

  def test_remove_hook_success
    token = "theghtoken"
    repo = repos(:brian_active_repo)

    stub_request(:delete, "https://api.github.com/repos/#{repo.name}/hooks/#{repo.hook_id}").
      with(headers: { "Authorization" => "token #{token}" }).
      to_return(status: 204)

    success = GithubApi.new(token).remove_hook(repo.name, repo.hook_id)
    assert success
  end

  def test_publish_pending_status
    token = "theghtoken"
    full_repo_name = "foo/bar"
    sha = "feedafacebeef"
    description = "The description"
    stub_request(:post, "https://api.github.com/repos/#{full_repo_name}/statuses/#{sha}").
      with(
        body: %({"context":"Fit Commit CI","description":"#{description}","state":"pending"}),
        headers: { "Authorization" => "token #{token}" }).
      to_return(
        status: 201,
        body: "{\"id\":132}",
        headers: { "Content-Type" => "application/json; charset=utf-8" }
      )

    status = GithubApi.new(token).publish_pending_status(full_repo_name, sha, description)
    assert_equal 132, status.id
  end

  def test_publish_success_status
    token = "theghtoken"
    full_repo_name = "foo/bar"
    sha = "feedafacebeef"
    description = "The description"
    stub_request(:post, "https://api.github.com/repos/#{full_repo_name}/statuses/#{sha}").
      with(
        body: %({"context":"Fit Commit CI","description":"#{description}","state":"success"}),
        headers: { "Authorization" => "token #{token}" }).
      to_return(
        status: 201,
        body: "{\"id\":132}",
        headers: { "Content-Type" => "application/json; charset=utf-8" }
      )

    status = GithubApi.new(token).publish_success_status(full_repo_name, sha, description)
    assert_equal 132, status.id
  end

  def test_publish_error_status
    token = "theghtoken"
    full_repo_name = "foo/bar"
    sha = "feedafacebeef"
    description = "The description"
    stub_request(:post, "https://api.github.com/repos/#{full_repo_name}/statuses/#{sha}").
      with(
        body: %({"context":"Fit Commit CI","description":"#{description}","state":"error"}),
        headers: { "Authorization" => "token #{token}" }).
      to_return(
        status: 201,
        body: "{\"id\":132}",
        headers: { "Content-Type" => "application/json; charset=utf-8" }
      )

    status = GithubApi.new(token).publish_error_status(full_repo_name, sha, description)
    assert_equal 132, status.id
  end

  def test_repository_true
    token = "theghtoken"
    full_repo_name = "foo/bar"

    stub_request(:get, "https://api.github.com/repos/#{full_repo_name}").
      with(headers: { "Authorization" => "token #{token}" }).
      to_return(status: 200)

    assert GithubApi.new(token).repository?(full_repo_name)
  end

  def test_repository_false
    token = "theghtoken"
    full_repo_name = "foo/bar"

    stub_request(:get, "https://api.github.com/repos/#{full_repo_name}").
      with(headers: { "Authorization" => "token #{token}" }).
      to_return(status: 404)

    assert_not GithubApi.new(token).repository?(full_repo_name)
  end
end
