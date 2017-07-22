require "test_helper"

class ReposControllerTest < ActionDispatch::IntegrationTest
  def test_view_repos_list
    user = users(:alice)
    sign_in_as(user)

    stub_github_user_repos([
      { id: 123, full_name: "alice/foo", private: false }
    ])

    get repos_url
    assert_select ".repo", 1
    assert_select ".repo", "alice/foo"
  end
end
