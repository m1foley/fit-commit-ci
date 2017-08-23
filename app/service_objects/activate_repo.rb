class ActivateRepo
  include ActiveModel::Model

  def initialize(repo, github_token)
    self.repo = repo
    self.github_token = github_token
  end

  def call
    fail NotImplementedError, "Private repos not yet supported" if repo.private?
    create_webhook && update_repo
  end

  private

  attr_accessor :repo, :github_token

  def create_webhook
    hook = github_api.create_hook(repo.name, builds_url)
    if repo.update(hook_id: hook.id)
      true
    else
      add_errors_from(repo)
      false
    end
  rescue GithubApi::HookAlreadyExists
    true
  rescue Octokit::Error => e
    errors.add(:base, e.message)
    false
  end

  def builds_url
    Rails.application.routes.url_helpers.builds_url(
      host: ENV.fetch("HOST"), protocol: ENV.fetch("PROTOCOL"))
  end

  def update_repo
    if repo.update(active: true)
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
