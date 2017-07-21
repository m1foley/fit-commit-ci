class SyncRepos
  GITHUB_ORGANIZATION_TYPE = "Organization".freeze

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
    self.remote_repo_hashes = github_client.repos
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

  def github_client
    Octokit::Client.new(access_token: user.github_token, auto_paginate: true)
  end

  def upsert_owner(owner_attributes)
    owner = Owner.find_or_initialize_by(github_id: owner_attributes[:id])
    attrs = {
      name: owner_attributes[:login],
      organization: (owner_attributes[:type] == GITHUB_ORGANIZATION_TYPE)
    }

    if owner.update(attrs)
      owner
    else
      Rails.logger.error("Error upserting owner: #{owner.error_messages_formatted}")
      nil
    end
  end

  def upsert_repo(remote_repo_hash, owner)
    repo = find_or_initialize_repo(remote_repo_hash)
    attrs = {
      private: remote_repo_hash[:private],
      github_id: remote_repo_hash[:id],
      name: remote_repo_hash[:full_name],
      in_organization: remote_repo_hash[:owner][:type] == GITHUB_ORGANIZATION_TYPE,
      owner: owner
    }

    if repo.update(attrs)
      repo
    else
      Rails.logger.error("Error upserting repo: #{repo.error_messages_formatted}")
      nil
    end
  end

  def find_or_initialize_repo(remote_repo_hash)
    Repo.find_by(github_id: remote_repo_hash[:id]) ||
      Repo.find_by(name: remote_repo_hash[:full_name]) ||
      Repo.new
  end
end
