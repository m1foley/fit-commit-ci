# frozen_string_literal: true

# https://developer.github.com/v3/repos/statuses/
#
# The Status API allows external services to mark commits with a success,
# failure, error, or pending state, which is then reflected in pull requests
# involving those commits.
class PublishStatus
  PENDING_MESSAGE = "Fit Commit CI is reviewing commit messages..."
  SUCCESS_MESSAGE_CLEAN = "All good!"

  def initialize(repo_name, sha, github_token)
    self.repo_name = repo_name
    self.sha = sha
    self.github_token = github_token
  end

  def publish_pending_status
    github_api.create_pending_status(repo_name, sha, PENDING_MESSAGE)
  end

  def publish_success_status(warning_count, error_count)
    message = success_message(warning_count, error_count)
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

  def success_message(warning_count, error_count)
    if warning_count == 0 && error_count == 0
      SUCCESS_MESSAGE_CLEAN
    elsif warning_count > 0 && error_count > 0
      format("Passed with %s and %s.",
        pluralize("error", error_count),
        pluralize("warning", warning_count)
      )
    elsif warning_count > 0
      format("Passed with %s.", pluralize("warning", warning_count))
    else
      format("Passed with %s.", pluralize("error", error_count))
    end
  end

  def pluralize(word, count)
    word += "s" if count != 1
    format("%d %s", count, word)
  end
end
