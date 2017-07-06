class ReposController < ApplicationController
  before_action :load_repos

  def index
  end

  private

  def load_repos
    @repos = github_client.repos.map do |repo_hash|
      Repo.new(
        github_id: repo_hash[:id],
        name: repo_hash[:full_name],
        private: repo_hash[:private]
      )
    end
  end

  def github_client
    @_github_client ||= Octokit::Client.new(
      access_token: current_user.github_token, auto_paginate: true)
  end
end
