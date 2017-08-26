class BuildsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_signin
  before_action :load_github_payload
  before_action :ignore_confirmation_pings

  def create
    head :ok
  end

  private

  def load_github_payload
    @github_payload = GithubPayload.new(params[:payload] || request.raw_post)
  end

  def ignore_confirmation_pings
    head :ok if @github_payload.confirmation_ping?
  end
end
