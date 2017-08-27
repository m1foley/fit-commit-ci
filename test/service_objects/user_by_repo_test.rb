require "test_helper"

class UserByRepoTest < ActiveSupport::TestCase
  def test_user_lost_repo_access
    user = users(:brian)
    repo = repos(:brian_inactive_repo)
    github_api_mock = mock
    github_api_mock.expects(:repository?).with(repo.name).returns(false)
    GithubApi.expects(:new).with(user.github_token).returns(github_api_mock)

    user_by_repo = UserByRepo.new(repo).call
    assert_equal Rails.application.secrets.fetch(:fcci_github_token), user_by_repo.github_token
    assert !user_by_repo.persisted?
    assert !repo.users.include?(user)
  end

  def test_repo_with_one_user
    user = users(:brian)
    repo = repos(:brian_inactive_repo)
    github_api_mock = mock
    github_api_mock.expects(:repository?).with(repo.name).returns(true)
    GithubApi.expects(:new).with(user.github_token).returns(github_api_mock)

    user_by_repo = UserByRepo.new(repo).call
    assert_equal user, user_by_repo
  end
end
