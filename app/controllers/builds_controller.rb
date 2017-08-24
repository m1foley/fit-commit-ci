class BuildsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_signin
  before_action :load_payload
  before_action :ignore_confirmation_pings

  def create
    head :ok
  end

  private

  def load_payload
    @payload = GithubPayload.new(params[:payload] || request.raw_post)
  end

  def ignore_confirmation_pings
    head :ok if @payload.confirmation_ping?
  end
end
