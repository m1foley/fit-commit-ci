class SessionsController < ApplicationController
  skip_before_action :require_user

  def create
    user = User.authenticate(params[:username], params[:password])

    if user
      session[:current_user_id] = user.id
      render text: "login success: #{user.id}"
    else
      render text: "login failure"
    end
  end
end
