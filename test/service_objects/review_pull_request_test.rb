require "test_helper"

class ReviewPullRequestTest < ActiveSupport::TestCase
  def test_repo_not_found
    github_payload = mock(head_sha: "abc", github_repo_id: 123123,
      full_repo_name: "foo/bar")
    SyncDataFromPayload.expects(:new).with(github_payload).returns(mock(:call))
    assert_no_difference("Build.count") do
      ReviewPullRequest.new(github_payload).call
    end
  end

  def test_action_not_relevant
    repo = repos(:brian_active_repo)
    github_payload = mock(head_sha: "abc", github_repo_id: repo.github_id,
      full_repo_name: "foo/bar")
    SyncDataFromPayload.expects(:new).with(github_payload).returns(mock(:call))
    PullRequest.expects(:new).with(github_payload).
      returns(mock(opened?: false, synchronize?: false))
    assert_no_difference("Build.count") do
      ReviewPullRequest.new(github_payload).call
    end
  end

  def test_success
    repo = repos(:brian_active_repo)
    user = users(:brian)
    head_sha = "abc123"
    github_payload = stub(head_sha: head_sha, github_repo_id: repo.github_id,
      full_repo_name: repo.name, pull_request_number: 4)
    SyncDataFromPayload.expects(:new).with(github_payload).returns(mock(:call))
    PullRequest.expects(:new).with(github_payload).
      returns(mock(opened?: false, synchronize?: true))
    mock_status_publisher = mock
    mock_status_publisher.expects(:publish_pending_status)
    mock_status_publisher.expects(:publish_success_status).with(1, 2)
    PublishStatus.expects(:new).with(repo.name, head_sha, user.github_token).
      returns(mock_status_publisher)
    ReviewBuild.expects(:new).with(any_parameters).returns(mock(call: [1, 2]))
    UserByRepo.expects(:new).with(repo).returns(mock(call: user))

    assert_difference("Build.count", 1) do
      ReviewPullRequest.new(github_payload).call
    end
    build = Build.order(:created_at).last
    assert_equal user, build.user
    assert_equal 4, build.pull_request_number
    assert_equal head_sha, build.head_sha
  end

  def test_build_not_saved
    repo = repos(:brian_active_repo)
    user = users(:brian)
    head_sha = "abc123"
    # invalid pull_request_number is an unrealistic scenario to make the build
    # save fail with a validation
    github_payload = stub(head_sha: head_sha, github_repo_id: repo.github_id,
      full_repo_name: repo.name, pull_request_number: -1)
    SyncDataFromPayload.expects(:new).with(github_payload).returns(mock(:call))
    PullRequest.expects(:new).with(github_payload).
      returns(mock(opened?: true))
    mock_status_publisher = mock
    mock_status_publisher.expects(:publish_pending_status)
    mock_status_publisher.expects(:publish_error_status).
      with("Pull request number must be greater than 0")
    PublishStatus.expects(:new).with(repo.name, head_sha, user.github_token).
      returns(mock_status_publisher)
    UserByRepo.expects(:new).with(repo).returns(mock(call: user))

    assert_no_difference("Build.count") do
      ReviewPullRequest.new(github_payload).call
    end
  end
end
