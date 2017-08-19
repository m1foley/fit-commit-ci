class GithubApi
  ORGANIZATION_TYPE = "Organization".freeze

  def initialize(token)
    self.token = token
  end

  def repos
    client.repos
  end

  private

  attr_accessor :token

  def client
    @client ||= Octokit::Client.new(access_token: token, auto_paginate: true)
  end
end
