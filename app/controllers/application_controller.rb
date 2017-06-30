class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_login

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= find_session_user || GuestUser.new
  end

  def find_session_user
    LoggedInUser.get(session[:remember_token])
  end

  def logged_in?
    current_user.logged_in?
  end

  def require_login
    return unless logged_in?
    render plain: "Login required"
    throw(:abort)
  end
end
