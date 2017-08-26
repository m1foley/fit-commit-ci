# Receiving a Payload from GitHub is an opportunity to keep our local data in
# sync with GitHub. Repos can change names or owners, etc.
class SyncDataFromPayload
  def initialize(github_payload)
    self.github_payload = github_payload
  end

  def call
    return true if !repo # only run for repos we care about
    owner = upsert_repo_owner
    owner && update_repo(owner)
  end

  private

  attr_accessor :github_payload

  def upsert_repo_owner
    Owner.upsert(
      github_id: github_payload.repository_owner_id,
      name: github_payload.repository_owner_name,
      organization: github_payload.repository_owner_is_organization?
    )
  end

  def update_repo(owner)
    repo.update(
      name: github_payload.full_repo_name,
      private: github_payload.private_repo?,
      owner: owner
    )
  end

  def repo
    @repo ||= Repo.active.find_by(github_id: github_payload.github_repo_id)
  end
end
