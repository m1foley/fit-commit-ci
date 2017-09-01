require "test_helper"

class PublishStatusTest < ActiveSupport::TestCase
  def test_publish_pending_status
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    github_api_mock = mock
    github_api_mock.expects(:create_pending_status).
      with(repo_name, sha, PublishStatus::PENDING_MESSAGE)
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).publish_pending_status
  end

  def test_publish_success_status_no_warnings
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    github_api_mock = mock
    github_api_mock.expects(:create_success_status).
      with(repo_name, sha, PublishStatus::SUCCESS_MESSAGE)
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).publish_success_status(0)
  end

  def test_publish_success_status_one_warning
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    github_api_mock = mock
    github_api_mock.expects(:create_success_status).
      with(repo_name, sha, PublishStatus::WARNING_MESSAGE_ONE)
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).publish_success_status(1)
  end

  def test_publish_success_status_multiple_warnings
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    github_api_mock = mock
    github_api_mock.expects(:create_success_status).
      with(repo_name, sha, "Passed with 2 warnings.")
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).publish_success_status(2)
  end

  def test_publish_error_status
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    error_message = "This is an error message."
    github_api_mock = mock
    github_api_mock.expects(:create_error_status).
      with(repo_name, sha, error_message)
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).
      publish_error_status(error_message)
  end
end
