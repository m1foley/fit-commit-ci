require "test_helper"

class PullRequestTest < ActiveSupport::TestCase
  def opened_payload
    GithubPayload.new(File.read("test/support/pull_request_opened_event.json"))
  end

  def synced_payload
    GithubPayload.new(File.read("test/support/pull_request_synchronize_event.json"))
  end

  def test_opened_true
    pr = PullRequest.new(opened_payload)
    assert pr.opened?
  end

  def test_opened_false
    pr = PullRequest.new(synced_payload)
    assert_not pr.opened?
  end

  def test_synchronize_true
    pr = PullRequest.new(synced_payload)
    assert pr.synchronize?
  end

  def test_synchronize_false
    pr = PullRequest.new(opened_payload)
    assert_not pr.synchronize?
  end
end
