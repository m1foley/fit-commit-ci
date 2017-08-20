require "test_helper"

class ActivateRepoTest < ActiveSupport::TestCase
  def callback_url
    "http://#{ENV.fetch("HOST")}/builds"
  end

  def test_activate_public_repo_hook_fails_to_create
    repo = repos(:brian_repo_1)
    GithubApi.any_instance.expects(:create_hook).with(repo.name, callback_url).
      returns(false)
    success = ActivateRepo.new(repo, "ghtoken").call
    assert !success
    repo.reload
    assert !repo.active?
    assert_nil repo.hook_id
  end

  def test_activate_public_repo_hook_already_exists
    repo = repos(:brian_repo_1)
    GithubApi.any_instance.expects(:create_hook).with(repo.name, callback_url).
      returns(:hook_already_exists)
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
