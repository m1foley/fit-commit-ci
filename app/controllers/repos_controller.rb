class ReposController < ApplicationController
  before_action :load_repos

  def index
  end

  private

  def load_repos
    @repos = current_user.repos
  end
end
