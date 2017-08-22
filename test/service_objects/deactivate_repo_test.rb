require "test_helper"

class DeactivateRepoTest < ActiveSupport::TestCase
  def test_deactivate_public_repo_hook_remove_failure
    repo = repos(:brian_active_repo)
    error = Octokit::TooManyRequests.new(method: :post, url: "https://theurl",
      status: 403, body: "Rate limit exceeded")
    GithubApi.any_instance.expects(:remove_hook).with(repo.name, repo.hook_id).
      raises(error)

    deactivator = DeactivateRepo.new(repo, "ghtoken")
    success = deactivator.call
    assert !success
    assert_equal "POST https://theurl: 403 - Rate limit exceeded",
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
    assert !repo.active?
    assert_nil repo.hook_id
  end
end
