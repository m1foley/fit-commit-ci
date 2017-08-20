class GithubApi
  ORGANIZATION_TYPE = "Organization".freeze

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
      :hook_already_exists
    else
      Rails.logger.error("Error creating hook for #{full_repo_name}: #{e.inspect}")
      false
    end
  end

  private

  attr_accessor :token

  def client
    @client ||= Octokit::Client.new(access_token: token, auto_paginate: true)
  end
end
