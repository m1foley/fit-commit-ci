require "test_helper"

class RepoTest < ActiveSupport::TestCase
  def test_organization
    repo = Repo.new(name: "foo/bar")
    assert_equal "foo", repo.organization
  end
end
