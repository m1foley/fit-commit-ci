require "test_helper"

class RepoTest < ActiveSupport::TestCase
  def test_organization
    repo = Repo.new(name: "foo/bar")
    assert_equal "foo", repo.organization
  end

  def test_remove_membership
    user = users(:brian)
    repo = repos(:brian_inactive_repo)
    assert_no_difference("User.count") do
      assert_difference("user.memberships.count", -1) do
        repo.remove_membership(user)
      end
    end
  end
end
