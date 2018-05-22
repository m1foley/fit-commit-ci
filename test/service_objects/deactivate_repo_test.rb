require "test_helper"

class DeactivateRepoTest < ActiveSupport::TestCase
  def test_deactivate_public_repo_hook_remove_failure
    repo = repos(:brian_active_repo)
    GithubApi.any_instance.expects(:remove_hook).with(repo.name, repo.hook_id).
      returns(false)

    deactivator = DeactivateRepo.new(repo, "ghtoken")
    success = deactivator.call
    assert_not success
    assert_equal "The hook was not able to be removed. There might be a syncing error.",
      deactivator.error_messages_formatted
    repo.reload
    assert repo.active?
    assert_not_nil repo.hook_id
  end

  def test_deactivate_public_repo_hook_remove_error
    repo = repos(:brian_active_repo)
    error = Octokit::TooManyRequests.new(method: :post, url: "https://theurl",
      status: 403, body: "Rate limit exceeded")
    GithubApi.any_instance.expects(:remove_hook).with(repo.name, repo.hook_id).
      raises(error)

    deactivator = DeactivateRepo.new(repo, "ghtoken")
    success = deactivator.call
    assert_not success
    assert_equal "POST https://theurl: 403 - Rate limit exceeded",
      deactivator.error_messages_formatted
    repo.reload
    assert repo.active?
    assert_not_nil repo.hook_id
  end

  def test_deactivate_public_repo_model_update_failure
    repo = repos(:brian_active_repo)
    # unrealistic scenario to make the model update fail with a validation
    repo.update(github_id: -1)
    GithubApi.any_instance.expects(:remove_hook).with(repo.name, repo.hook_id).
      returns(true)

    deactivator = DeactivateRepo.new(repo, "ghtoken")
    success = deactivator.call
    assert_not success
    assert_equal "Github must be greater than 0",
      deactivator.error_messages_formatted
    repo.reload
    assert repo.active?
    assert_not_nil repo.hook_id
  end

  def test_deactivate_public_repo
    repo = repos(:brian_active_repo)
    GithubApi.any_instance.expects(:remove_hook).with(repo.name, repo.hook_id).
      returns(true)
    success = DeactivateRepo.new(repo, "ghtoken").call
    assert success
    repo.reload
    assert_not repo.active?
    assert_nil repo.hook_id
  end
end
