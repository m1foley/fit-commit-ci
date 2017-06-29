class SessionsController < ApplicationController
  skip_before_action :require_login

  def create
    user = update_or_create_user
    if user
      session[:remember_token] = user.remember_token
      Rails.logger.info(request.env["omniauth.auth"])
      render plain: "Login success! #{user.inspect}"
    else
      flash[:error] = "Error logging in"
      redirect_to root_path
    end
  end

  private

  def update_or_create_user
    user = find_user
    if user
      update_user(user)
    else
      create_user
    end
  end

  def update_user(user)
    if user.update(github_token: github_token)
      user
    else
      Rails.logger.error("Error updating user on login: #{user.errors.full_messages}")
      nil
    end
  end

  def find_user
    User.find_by(username: github_username)
  end

  def create_user
    user = User.new(
      username: github_username,
      github_token: github_token,
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

  def github_token
    request.env["omniauth.auth"]["credentials"]["token"]
  end

  def generate_remember_token
    SecureRandom.hex(20)
  end
end
