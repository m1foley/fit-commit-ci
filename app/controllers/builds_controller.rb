class BuildsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_signin

  def create
    head :ok
  end
end
