require "test_helper"

class SyncDataFromPayloadTest < ActiveSupport::TestCase
  def test_github_id_not_found
    payload = mock(github_repo_id: 123123123)
    syncer = SyncDataFromPayload.new(payload)
    assert syncer.call
  end

  def test_inactive_repo
    repo = repos(:brian_inactive_repo)
    old_repo_name = repo.name
    payload = mock(github_repo_id: repo.github_id)
    syncer = SyncDataFromPayload.new(payload)
    assert syncer.call
    repo.reload
    assert_equal old_repo_name, repo.name
  end

  def test_update_owner_and_repo
    repo = repos(:brian_active_repo)
    owner = repo.owner
    payload = mock(
      github_repo_id: repo.github_id,
      full_repo_name: "brian/new_name",
      private_repo?: true,
      repository_owner_id: owner.github_id,
      repository_owner_name: "new_owner_name",
      repository_owner_is_organization?: false
    )
    syncer = SyncDataFromPayload.new(payload)
    assert syncer.call
    repo.reload
    assert_equal "brian/new_name", repo.name
    assert repo.private?
    owner.reload
    assert_equal owner, repo.owner
    assert_equal "new_owner_name", owner.name
  end

  def test_new_owner
    repo = repos(:brian_active_repo)
    payload = mock(
      github_repo_id: repo.github_id,
      full_repo_name: "brian/new_name",
      private_repo?: true,
      repository_owner_id: 123123,
      repository_owner_name: "new_owner_name",
      repository_owner_is_organization?: false
    )
    syncer = SyncDataFromPayload.new(payload)
    assert syncer.call
    repo.reload
    assert_equal "brian/new_name", repo.name
    assert repo.private?
    new_owner = Owner.find_by!(github_id: 123123)
    assert_equal new_owner, repo.owner
    assert_equal "new_owner_name", new_owner.name
  end
end
