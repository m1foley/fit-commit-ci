# A repo can change its name, etc. Keep our local data in sync with GitHub.
class UpdateRepoAttributes
  def initialize(github_payload)
    self.github_payload = github_payload
  end

  def call
    repo = fetch_repo
    repo && repo.update(attributes_from_payload)
  end

  private

  attr_accessor :github_payload

  def fetch_repo
    Repo.active.find_by(github_id: github_payload.github_repo_id)
  end

  def attributes_from_payload
    {
      name: github_payload.full_repo_name,
      private: github_payload.private_repo?
    }
  end
end
