class ActivationsController < ApplicationController
  before_action :load_repo
  before_action :ensure_repo_allowed

  def create
    if !ActivateRepo.new(@repo, current_user.github_token).call
      flash[:error] = "There was an error activating #{@repo.name}."
      redirect_to :repos
    end
  end

  private

  def load_repo
    @repo = current_user.repos.with_membership_status.
      find_by(id: params[:repo_id])
    unless @repo
      flash[:error] = "Repo not found"
      redirect_to :repos
    end
  end

  def ensure_repo_allowed
    if @repo.private?
      flash[:error] = "Sorry, private repos are not supported yet."
      redirect_to :repos
    end
  end
end
