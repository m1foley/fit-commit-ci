require "test_helper"

class UserByRepoTest < ActiveSupport::TestCase
  def test_user_lost_repo_access
    user = users(:brian)
    repo = repos(:brian_inactive_repo)
    github_api_mock = mock
    github_api_mock.expects(:repository?).with(repo.name).returns(false)
    GithubApi.expects(:new).with(user.github_token).returns(github_api_mock)

    user_by_repo = UserByRepo.new(repo).call
    assert_equal Rails.application.credentials.fcci_github_token, user_by_repo.github_token
    assert_not user_by_repo.persisted?
    assert_not repo.users.include?(user)
  end

  def test_repo_with_one_user
    user = users(:brian)
    repo = repos(:brian_inactive_repo)
    github_api_mock = mock
    github_api_mock.expects(:repository?).with(repo.name).returns(true)
    GithubApi.expects(:new).with(user.github_token).returns(github_api_mock)

    assert_equal user, UserByRepo.new(repo).call
  end

  def test_repo_with_multiple_users
    user1 = users(:caesar)
    user2 = users(:diocletian)
    repo = repos(:roman_emperors_repo)
    github_api_mock = mock
    github_api_mock.expects(:repository?).with(repo.name).returns(true)
    GithubApi.expects(:new).
      with(any_of(user1.github_token, user2.github_token)).
      returns(github_api_mock)

    assert_includes [user1, user2], UserByRepo.new(repo).call
  end
end
