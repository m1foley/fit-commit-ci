require "test_helper"

class SyncReposTest < ActiveSupport::TestCase
  def test_no_github_data
    user = users(:alice)
    stub_github_user_repos([])
    assert_no_difference("Repo.count") do
      SyncRepos.new(user).call
    end
  end

  def test_github_data
    user = users(:alice)
    stub_github_user_repos([
      {
        id: 123, full_name: "alice/foo", private: false,
        permissions: { admin: true },
        owner: { id: 1, login: user.username }
      }
    ])

    assert_difference(["Repo.count", "Owner.count", "Membership.count"], 1) do
      SyncRepos.new(user).call
    end

    repo = Repo.order(:created_at).last
    assert_equal 123, repo.github_id
    assert_equal "alice/foo", repo.name
    assert !repo.private?
    assert !repo.active?
    assert !repo.in_organization?
    assert user.repos.reload.include?(repo)

    owner = Owner.order(:created_at).last
    assert_equal owner, repo.owner
    assert_equal 1, owner.github_id
    assert_equal user.username, owner.name
    assert !owner.organization?
  end
end
