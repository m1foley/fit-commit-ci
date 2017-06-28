class SessionsController < ApplicationController
  skip_before_action :require_login

  def create
    user = find_user || create_user

    if user
      session[:remember_token] = user.remember_token
      Rails.logger.info(request.env["omniauth.auth"])
      render plain: "Login success! #{user.inspect}"
    else
      flash[:error] = "Error creating user"
      redirect_to root_path
    end
  end

  private

  def find_user
    User.find_by(username: github_username)
  end

  def create_user
    user = User.new(
      username: github_username,
      remember_token: generate_remember_token
    )

    if user.save
      user
    else
      Rails.logger.error("Error creating user: #{user.errors.full_messages}")
      nil
    end
  end

  def github_username
    request.env["omniauth.auth"]["info"]["nickname"]
  end

  # def github_token
  #   request.env["omniauth.auth"]["credentials"]["token"]
  # end

  def generate_remember_token
    SecureRandom.hex(20)
  end
end
