require "test_helper"

class RepoSyncsControllerTest < ActionDispatch::IntegrationTest
  def test_create
    user = users(:alice)
    sign_in_as(user)
    SyncRepos.expects(:new).with(user).returns(mock(call: true))

    post repo_syncs_url, xhr: true
    assert_turbolinks_redirect(repos_url)
  end
end
