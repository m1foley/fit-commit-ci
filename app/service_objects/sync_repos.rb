class SyncRepos
  def initialize(user)
    self.user = user
  end

  def call
    fetch_remote_repo_hashes
    delete_user_memberships
    create_user_memberships
  end

  private

  attr_accessor :user, :remote_repo_hashes

  def fetch_remote_repo_hashes
    self.remote_repo_hashes = github_api.repos
  end

  def github_api
    GithubApi.new(user.github_token)
  end

  def delete_user_memberships
    user.memberships.delete_all
  end

  def create_user_memberships
    # The transaction ensures all inserts will happen together or not at all,
    # which should lead to more consistent repo syncs.
    Repo.transaction do
      remote_repo_hashes.each do |remote_repo_hash|
        create_user_membership(remote_repo_hash)
      end
    end
  end

  def create_user_membership(remote_repo_hash)
    owner = upsert_owner(remote_repo_hash[:owner]) || return
    repo = upsert_repo(remote_repo_hash, owner) || return

    membership = user.memberships.build(
      repo: repo,
      admin: remote_repo_hash[:permissions][:admin]
    )

    if membership.save
      membership
    else
      Rails.logger.error("Error creating membership: #{membership.error_messages_formatted}")
    end
  rescue => e
    Rails.logger.error("Error creating membership: #{e.inspect} #{e.backtrace}")
  end

  def upsert_owner(owner_attributes)
    Owner.upsert(
      github_id: owner_attributes[:id],
      name: owner_attributes[:login],
      organization: (owner_attributes[:type] == GithubApi::ORGANIZATION_TYPE)
    )
  end

  def upsert_repo(remote_repo_hash, owner)
    Repo.upsert(
      github_id: remote_repo_hash[:id],
      private: remote_repo_hash[:private],
      name: remote_repo_hash[:full_name],
      in_organization: remote_repo_hash[:owner][:type] == GithubApi::ORGANIZATION_TYPE,
      owner: owner
    )
  end
end
