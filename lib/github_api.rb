# frozen_string_literal: true

class GithubApi
  ORGANIZATION_TYPE = "Organization"
  STATUS_CONTEXT = "Fit Commit CI"
  PENDING_STATUS = "pending"
  SUCCESS_STATUS = "success"
  ERROR_STATUS = "error"
  HookAlreadyExists = Class.new(StandardError)

  def initialize(token)
    self.token = token
  end

  def repos
    client.repos
  end

  def create_hook(full_repo_name, callback_endpoint)
    Rails.logger.info("Creating hook. Repo: #{full_repo_name}, URL: #{callback_endpoint}")
    client.create_hook(
      full_repo_name,
      "web",
      { url: callback_endpoint },
      { events: [ "pull_request" ], active: true }
    )
  rescue Octokit::UnprocessableEntity => e
    if e.message.include?("Hook already exists")
      Rails.logger.info(e.message)
      raise HookAlreadyExists, e
    else
      Rails.logger.error("Error creating hook: #{e.inspect}")
      raise
    end
  rescue Octokit::Error => e
    Rails.logger.error("Error creating hook: #{e.inspect}")
    raise
  end

  def remove_hook(full_repo_name, hook_id)
    Rails.logger.info("Removing hook #{hook_id} for repo #{full_repo_name}")
    client.remove_hook(full_repo_name, hook_id)
  rescue Octokit::Error => e
    Rails.logger.error("Error removing hook: #{e.inspect}")
    raise
  end

  def publish_pending_status(full_repo_name, sha, description)
    publish_status(
      full_repo_name,
      sha,
      PENDING_STATUS,
      description
    )
  end

  def publish_success_status(full_repo_name, sha, description)
    publish_status(
      full_repo_name,
      sha,
      SUCCESS_STATUS,
      description
    )
  end

  def publish_error_status(full_repo_name, sha, description)
    publish_status(
      full_repo_name,
      sha,
      ERROR_STATUS,
      description
    )
  end

  def repository?(full_repo_name)
    client.repository?(full_repo_name)
  rescue Octokit::Unauthorized
    false
  end

  private

  attr_accessor :token

  def client
    @client ||= Octokit::Client.new(access_token: token, auto_paginate: true)
  end

  def publish_status(full_repo_name, sha, state, description)
    Rails.logger.info(format("Publishing GitHub status. Repo: %s, SHA: %s, state: %s, description: %s",
      full_repo_name, sha, state, description))

    client.create_status(
      full_repo_name,
      sha,
      state,
      context: STATUS_CONTEXT,
      description: description
    )
  end
end
