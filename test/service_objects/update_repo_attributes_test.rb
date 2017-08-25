require "test_helper"

class UpdateRepoAttributesTest < ActiveSupport::TestCase
  def test_github_id_not_found
    payload = mock(github_repo_id: 123123123)
    updater = UpdateRepoAttributes.new(payload)
    assert !updater.call
  end

  def test_inactive_repo
    repo = repos(:brian_inactive_repo)
    payload = mock(github_repo_id: repo.github_id)
    updater = UpdateRepoAttributes.new(payload)
    assert !updater.call
  end

  def test_updates
    repo = repos(:brian_active_repo)
    payload = mock(
      github_repo_id: repo.github_id,
      full_repo_name: "brian/new_name",
      private_repo?: true
    )
    updater = UpdateRepoAttributes.new(payload)
    assert updater.call
    repo.reload
    assert_equal "brian/new_name", repo.name
    assert repo.private?
  end
end
