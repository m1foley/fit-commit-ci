require "test_helper"

class ActivateRepoTest < ActiveSupport::TestCase
  def callback_url
    "http://#{ENV.fetch("HOST")}/builds"
  end

  def test_activate_public_repo_hook_fails_to_create
    repo = repos(:brian_repo_1)
    error = Octokit::TooManyRequests.new(method: :post, url: "https://theurl",
      status: 403, body: "Rate limit exceeded")
    GithubApi.any_instance.expects(:create_hook).with(repo.name, callback_url).
      raises(error)

    activator = ActivateRepo.new(repo, "ghtoken")
    success = activator.call
    assert !success
    assert_equal "POST https://theurl: 403 - Rate limit exceeded",
      activator.error_messages_formatted
    repo.reload
    assert !repo.active?
    assert_nil repo.hook_id
  end

  def test_activate_public_repo_hook_already_exists
    repo = repos(:brian_repo_1)
    GithubApi.any_instance.expects(:create_hook).with(repo.name, callback_url).
      raises(GithubApi::HookAlreadyExists)
    success = ActivateRepo.new(repo, "ghtoken").call
    assert success
    repo.reload
    assert repo.active?
    assert_nil repo.hook_id
  end

  def test_activate_public_repo
    repo = repos(:brian_repo_1)
    GithubApi.any_instance.expects(:create_hook).with(repo.name, callback_url).
      returns(Struct.new(:id).new(132))
    success = ActivateRepo.new(repo, "ghtoken").call
    assert success
    repo.reload
    assert repo.active?
    assert_equal 132, repo.hook_id
  end
end
