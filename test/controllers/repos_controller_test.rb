require "test_helper"

class ReposControllerTest < ActionDispatch::IntegrationTest
  def test_index_empty
    user = users(:alice)
    sign_in_as(user)

    get repos_url
    assert_select ".repo", false
  end

  def test_index
    user = users(:brian)
    sign_in_as(user)

    get repos_url
    assert_select ".repo", 1
    assert_select ".repo", user.repos.take.name
  end
end
