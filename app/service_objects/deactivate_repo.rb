class DeactivateRepo
  include ActiveModel::Model

  def initialize(repo, github_token)
    self.repo = repo
    self.github_token = github_token
  end

  def call
    fail NotImplementedError, "Private repos not yet supported" if repo.private?
    remove_webhook && repo.update(hook_id: nil, active: false)
  end

  private

  attr_accessor :repo, :github_token

  def remove_webhook
    github_api.remove_hook(repo.name, repo.hook_id)
  rescue Octokit::Error => e
    errors.add(:base, e.message)
    false
  end

  def github_api
    GithubApi.new(github_token)
  end
end
