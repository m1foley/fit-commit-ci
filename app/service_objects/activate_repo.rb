class ActivateRepo
  def initialize(repo, github_token)
    self.repo = repo
    self.github_token = github_token
  end

  def call
    fail NotImplementedError, "Private repos not yet supported" if repo.private?
    create_webhook && repo.update(active: true)
  end

  private

  attr_accessor :repo, :github_token

  def create_webhook
    hook = github_api.create_hook(repo.name, builds_url)
    return hook if !hook || hook == :hook_already_exists
    repo.update(hook_id: hook.id)
  end

  def builds_url
    Rails.application.routes.url_helpers.builds_url(
      host: ENV.fetch("HOST"), protocol: ENV.fetch("PROTOCOL"))
  end

  def github_api
    GithubApi.new(github_token)
  end
end
