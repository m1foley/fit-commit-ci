class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_signin

  helper_method :current_user, :signed_in?

  private

  def current_user
    @current_user ||= find_session_user || GuestUser.new
  end

  def find_session_user
    SignedInUser.get(session[:remember_token])
  end

  def signed_in?
    current_user.signed_in?
  end

  def require_signin
    return unless signed_in?
    render plain: "Sign in required"
    throw(:abort)
  end
end
