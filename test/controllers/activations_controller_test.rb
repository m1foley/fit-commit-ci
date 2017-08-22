require "test_helper"

class ActivationsControllerTest < ActionDispatch::IntegrationTest
  def test_success
    user = users(:brian)
    repo = repos(:brian_inactive_repo)
    sign_in_as(user)
    hook_id = stub_github_create_hook(repo)

    post repo_activation_url(repo), xhr: true
    assert_equal "text/javascript", @response.content_type
    assert @response.body.include?(repo.id.to_s)
    assert @response.body.include?("repo--active")
    assert flash[:error].blank?
    repo.reload
    assert_equal hook_id, repo.hook_id
    assert repo.active?
  end

  def test_activation_fail
    user = users(:brian)
    repo = repos(:brian_inactive_repo)
    sign_in_as(user)
    stub_github_create_hook_fail(repo, "Error123")

    post repo_activation_url(repo), xhr: true
    assert_turbolinks_redirect(repos_url)
    assert_equal "POST https://api.github.com/repos/#{repo.name}/hooks: 400 - Error123", flash[:error]
    repo.reload
    assert_nil repo.hook_id
    assert !repo.active?
  end

  def test_repo_not_found
    user = users(:brian)
    sign_in_as(user)

    post repo_activation_url("invalid_id"), xhr: true
    assert_turbolinks_redirect(repos_url)
    assert_equal "Repo not found", flash[:error]
  end

  def test_private_repo
    user = users(:brian)
    repo = repos(:brian_private_repo)
    sign_in_as(user)

    post repo_activation_url(repo), xhr: true
    assert_turbolinks_redirect(repos_url)
    assert_match(/private repos are not supported/, flash[:error])
  end
end
