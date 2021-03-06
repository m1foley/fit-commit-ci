class SessionsController < ApplicationController
  skip_before_action :require_signin

  def create
    user = update_or_create_user
    if user
      session[:remember_token] = user.remember_token
    else
      flash[:error] = "Error signing in"
    end
    redirect_to root_path
  end

  def destroy
    session[:remember_token] = nil
    redirect_to root_path
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
      Rails.logger.error("Error updating user on signin: #{user.errors.full_messages}")
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
      SyncRepos.new(user).call
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
