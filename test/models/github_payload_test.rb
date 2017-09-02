require "test_helper"

class GithubPayloadTest < ActiveSupport::TestCase
  def opened_pull_request_payload
    GithubPayload.new(
      File.read("test/support/pull_request_opened_event.json"))
  end

  def synced_pull_request_payload
    GithubPayload.new(
      File.read("test/support/pull_request_synchronize_event.json"))
  end

  def confirmation_ping_payload
    GithubPayload.new("{\"zen\":\"abc\"}")
  end

  def empty_payload
    GithubPayload.new("{}")
  end

  def test_pull_request_when_empty
    assert !empty_payload.pull_request?
  end

  def test_pull_request_when_opened
    assert opened_pull_request_payload.pull_request?
  end

  def test_pull_request_when_synced
    assert synced_pull_request_payload.pull_request?
  end

  def test_pull_request_when_non_pr
    assert !confirmation_ping_payload.pull_request?
  end

  def test_confirmation_ping_false
    assert !opened_pull_request_payload.confirmation_ping?
  end

  def test_confirmation_ping_empty
    assert !empty_payload.confirmation_ping?
  end

  def test_confirmation_ping_true
    assert confirmation_ping_payload.confirmation_ping?
  end

  def test_repo_attributes
    payload = opened_pull_request_payload
    assert_equal 101233233, payload.github_repo_id
    assert_equal "m1foley/fcci_test", payload.full_repo_name
    assert !payload.private_repo?
  end

  def test_owner_attributes
    payload = opened_pull_request_payload
    assert_equal 199775, payload.repository_owner_id
    assert_equal "m1foley", payload.repository_owner_name
    assert !payload.repository_owner_is_organization?
  end

  def test_action
    assert_equal "synchronize", synced_pull_request_payload.action
  end

  def test_head_sha
    assert_equal "e6a4ccf95262cf5c73ac5786d49a82240b1f1157",
      opened_pull_request_payload.head_sha
    assert_nil empty_payload.head_sha
  end

  def test_pull_request_number
    assert_equal 2, opened_pull_request_payload.pull_request_number
    assert_nil empty_payload.pull_request_number
  end
end
