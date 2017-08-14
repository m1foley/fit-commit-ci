class ActivateRepo
  def initialize(repo, github_token)
    self.repo = repo
    self.github_token = github_token
  end

  def call
    fail NotImplementedError, "Private repos not yet supported" if repo.private?
  end

  private

  attr_accessor :repo, :github_token
end
