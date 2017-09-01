# frozen_string_literal: true

# https://developer.github.com/v3/repos/statuses/
#
# The Status API allows external services to mark commits with a success,
# failure, error, or pending state, which is then reflected in pull requests
# involving those commits.
class PublishStatus
  PENDING_MESSAGE = "Fit Commit CI is reviewing commit messages..."
  SUCCESS_MESSAGE = "All good!"
  WARNING_MESSAGE_ONE = "Passed with 1 warning."
  WARNING_MESSAGE_MULTI = "Passed with %<warning_count>d warnings."

  def initialize(repo_name, sha, github_token)
    self.repo_name = repo_name
    self.sha = sha
    self.github_token = github_token
  end

  def publish_pending_status
    github_api.create_pending_status(repo_name, sha, PENDING_MESSAGE)
  end

  def publish_success_status(warning_count)
    message = success_message(warning_count)
    github_api.create_success_status(repo_name, sha, message)
  end

  def publish_error_status(message)
    github_api.create_error_status(repo_name, sha, message)
  end

  private

  attr_accessor :repo_name, :sha, :github_token

  def github_api
    @github_api ||= GithubApi.new(github_token)
  end

  def success_message(warning_count)
    case warning_count
    when 0
      SUCCESS_MESSAGE
    when 1
      WARNING_MESSAGE_ONE
    else
      format(WARNING_MESSAGE_MULTI, warning_count: warning_count)
    end
  end
end
