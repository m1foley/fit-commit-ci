class DeactivateRepo
  include ActiveModel::Model

  def initialize(repo, github_token)
    self.repo = repo
    self.github_token = github_token
  end

  def call
    fail NotImplementedError, "Private repos not yet supported" if repo.private?
    remove_webhook && update_repo
  end

  private

  attr_accessor :repo, :github_token

  def remove_webhook
    if github_api.remove_hook(repo.name, repo.hook_id)
      true
    else
      errors.add(:base, "The hook was not able to be removed. There might be a syncing error.")
      false
    end
  rescue Octokit::Error => e
    errors.add(:base, e.message)
    false
  end

  def update_repo
    if repo.update(hook_id: nil, active: false)
      true
    else
      add_errors_from(repo)
      false
    end
  end

  def github_api
    GithubApi.new(github_token)
  end
end
