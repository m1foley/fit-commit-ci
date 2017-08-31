require "test_helper"

class GithubPayloadTest < ActiveSupport::TestCase
  def pull_request_opened_json
    File.read("test/support/pull_request_opened_event.json")
  end

  def pull_request_synced_json
    File.read("test/support/pull_request_synchronize_event.json")
  end

  def confirmation_ping_json
    "{\"zen\":\"abc\"}"
  end

  def test_pull_request_when_empty
    payload = GithubPayload.new("{}")
    assert !payload.pull_request?
  end

  def test_pull_request_when_opened
    payload = GithubPayload.new(pull_request_opened_json)
    assert payload.pull_request?
  end

  def test_pull_request_when_synced
    payload = GithubPayload.new(pull_request_synced_json)
    assert payload.pull_request?
  end

  def test_pull_request_when_non_pr
    payload = GithubPayload.new(confirmation_ping_json)
    assert !payload.pull_request?
  end

  def test_confirmation_ping_false
    payload = GithubPayload.new(pull_request_opened_json)
    assert !payload.confirmation_ping?
  end

  def test_confirmation_ping_empty
    payload = GithubPayload.new("{}")
    assert !payload.confirmation_ping?
  end

  def test_confirmation_ping_true
    payload = GithubPayload.new(confirmation_ping_json)
    assert payload.confirmation_ping?
  end

  def test_repo_attributes
    payload = GithubPayload.new(pull_request_opened_json)
    assert_equal 101233233, payload.github_repo_id
    assert_equal "m1foley/fcci_test", payload.full_repo_name
    assert !payload.private_repo?
  end

  def test_owner_attributes
    payload = GithubPayload.new(pull_request_opened_json)
    assert_equal 199775, payload.repository_owner_id
    assert_equal "m1foley", payload.repository_owner_name
    assert !payload.repository_owner_is_organization?
  end

  def test_action
    payload = GithubPayload.new(pull_request_synced_json)
    assert_equal "synchronize", payload.action
  end

  def test_head_sha
    payload = GithubPayload.new(pull_request_opened_json)
    assert_equal "e6a4ccf95262cf5c73ac5786d49a82240b1f1157", payload.head_sha
    assert_nil GithubPayload.new("{}").head_sha
  end
end
