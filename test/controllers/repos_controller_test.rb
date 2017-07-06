require "test_helper"

class ReposControllerTest < ActionDispatch::IntegrationTest
  test "viewing repos list" do
    user = users(:alice)
    sign_in_as(user)

    github_data = [{ id: 123, full_name: "alice/foo", private: false }]
    stub_request(:get, %r(https://api\.github\.com/user/repos)).
      to_return(status: 200, body: github_data)

    get repos_url
    assert_select ".repo", 1
    assert_select ".repo", "alice/foo"
  end
end
