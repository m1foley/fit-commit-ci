require "test_helper"

class PublishStatusTest < ActiveSupport::TestCase
  def test_publish_pending_status
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    github_api_mock = mock
    github_api_mock.expects(:publish_pending_status).
      with(repo_name, sha, PublishStatus::PENDING_MESSAGE)
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).publish_pending_status
  end

  def test_publish_success_status_empty_counts
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    github_api_mock = mock
    github_api_mock.expects(:publish_success_status).
      with(repo_name, sha, PublishStatus::SUCCESS_MESSAGE_CLEAN)
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).publish_success_status(0, 0)
  end

  def test_publish_success_status_only_warnings
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    github_api_mock = mock
    github_api_mock.expects(:publish_success_status).
      with(repo_name, sha, "Passed with 1 warning.")
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).publish_success_status(1, 0)
  end

  def test_publish_success_status_only_errors
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    github_api_mock = mock
    github_api_mock.expects(:publish_success_status).
      with(repo_name, sha, "Passed with 2 errors.")
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).publish_success_status(0, 2)
  end

  def test_publish_success_status_errors_and_warnings
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    github_api_mock = mock
    github_api_mock.expects(:publish_success_status).
      with(repo_name, sha, "Passed with 1 error and 2 warnings.")
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).publish_success_status(2, 1)
  end

  def test_publish_error_status
    repo_name = "foo/bar"
    sha = "feedafacebeefabeef"
    github_token = "gtok123"
    error_message = "This is an error message."
    github_api_mock = mock
    github_api_mock.expects(:publish_error_status).
      with(repo_name, sha, error_message)
    GithubApi.expects(:new).with(github_token).returns(github_api_mock)
    PublishStatus.new(repo_name, sha, github_token).
      publish_error_status(error_message)
  end
end
