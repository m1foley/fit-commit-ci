class UserByRepo
  def initialize(repo)
    self.repo = repo
  end

  def call
    user = repo.users.where.not(github_token: nil).
      order(Arel.sql("RANDOM()")).
      detect { |repo_user| can_access_repository?(repo_user) }
    user || fcci_user
  end

  private

  attr_accessor :repo

  def can_access_repository?(user)
    if GithubApi.new(user.github_token).repository?(repo.name)
      true
    else
      Rails.logger.info("Repo user can't access repo #{repo.name}. Removing membership: #{user.username}")
      repo.remove_membership(user)
      false
    end
  end

  def fcci_user
    User.new(github_token: Rails.application.credentials.fcci_github_token)
  end
end
