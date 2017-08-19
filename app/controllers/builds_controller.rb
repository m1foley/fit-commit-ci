class BuildsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :require_signin, only: [:create]

  def index
    head :no_content
  end

  def create
    head :no_content
  end
end
