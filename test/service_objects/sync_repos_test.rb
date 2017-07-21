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

    membership = Membership.order(:created_at).last
    assert membership.admin?
  end

  def test_delete_repos
    user = users(:alice)
    stub_github_user_repos([
      {
        id: 1, full_name: "alice/foo", private: false,
        permissions: { admin: true },
        owner: { id: 1, login: user.username }
      }
    ])
    SyncRepos.new(user).call

    stub_github_user_repos([])
    assert_difference("Membership.count", -1) do
      assert_no_difference(["Owner.count", "Repo.count"]) do
        SyncRepos.new(user).call
      end
    end
  end

  def test_upserts
    user = users(:alice)
    assert_difference(["Membership.count", "Repo.count"], 2) do
      assert_difference("Owner.count", 1) do
        stub_github_user_repos([
          {
            id: 1, full_name: "alice/foo", private: false,
            permissions: { admin: true },
            owner: { id: 1, login: user.username }
          }
        ])
        SyncRepos.new(user).call

        stub_github_user_repos([
          {
            id: 1, full_name: "alice/foo_renamed", private: true,
            permissions: { admin: false },
            owner: { id: 1, login: "new_owner_name" }
          },
          {
            id: 2, full_name: "alice/bar", private: true,
            permissions: { admin: false },
            owner: { id: 1, login: "new_owner_name" }
          }
        ])

        SyncRepos.new(user).call
      end

      repos = user.repos.reload
      assert_equal [ 1, 2 ], repos.map(&:github_id).sort
      assert_equal [ "alice/bar", "alice/foo_renamed" ], repos.map(&:name).sort
      assert repos.all?(&:private?)
      assert repos.none?(&:active?)
      assert repos.none?(&:in_organization?)

      memberships = user.memberships.reload
      assert memberships.none?(&:admin?)

      owner = Owner.order(:created_at).last
      assert_equal "new_owner_name", owner.name
    end
  end
end
