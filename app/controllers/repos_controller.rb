class ReposController < ApplicationController
  before_action :load_repos_by_organization

  def index
  end

  private

  def load_repos_by_organization
    @repos_by_organization = current_user.repos.with_membership_status.
      order("memberships.admin DESC").
      order(active: :desc).
      order(Repo.arel_table["name"].lower.asc).
      group_by(&:organization)
  end
end
