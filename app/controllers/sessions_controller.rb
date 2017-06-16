class SessionsController < ApplicationController
  skip_before_action :require_user

  def create
    user = nil

    if user
      session[:current_user_id] = user.id
      render plain: "login success: #{user.id}"
    else
      render plain: "login failure"
    end
  end
end
