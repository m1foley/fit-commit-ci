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
    client.create_hook(
      full_repo_name,
      "web",
      { url: callback_endpoint },
      { events: [ "pull_request" ], active: true }
    )
  rescue Octokit::Error => e
    if e.message.include?("Hook already exists")
      Rails.logger.info("Hook already exists: #{full_repo_name}")
      raise HookAlreadyExists, e
    else
      Rails.logger.error("Error creating hook for #{full_repo_name}: #{e.inspect}")
      raise
    end
  end

  def remove_hook(full_repo_name, hook_id)
    client.remove_hook(full_repo_name, hook_id)
  rescue Octokit::Error => e
    Rails.logger.error("Error removing hook #{hook_id} for #{full_repo_name}: #{e.inspect}")
    raise
  end

  def create_pending_status(full_repo_name, sha, description)
    create_status(
      full_repo_name,
      sha,
      PENDING_STATUS,
      description
    )
  end

  def create_success_status(full_repo_name, sha, description)
    create_status(
      full_repo_name,
      sha,
      SUCCESS_STATUS,
      description
    )
  end

  def create_error_status(full_repo_name, sha, description)
    create_status(
      full_repo_name,
      sha,
      ERROR_STATUS,
      description
    )
  end

  private

  attr_accessor :token

  def client
    @client ||= Octokit::Client.new(access_token: token, auto_paginate: true)
  end

  def create_status(repo, sha, state, description)
    client.create_status(
      repo,
      sha,
      state,
      context: STATUS_CONTEXT,
      description: description
    )
  end
end
