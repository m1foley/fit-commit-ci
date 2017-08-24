class RepoSyncsController < ApplicationController
  def create
    SyncRepos.new(current_user).call
    redirect_to repos_path
  end
end
