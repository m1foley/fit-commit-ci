class ReposController < ApplicationController
  before_action :load_repos_by_organization

  def index
  end

  private

  def load_repos_by_organization
    @repos_by_organization = current_user.repos.
      select("repos.*", "memberships.admin AS current_user_admin").
      order("memberships.admin DESC").
      order(active: :desc).
      order("LOWER(name) ASC").
      group_by(&:organization)
  end
end
