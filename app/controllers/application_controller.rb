class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_login

  private

  def current_user
    @current_user ||= LoggedInUser.get(session[:current_user_id]) ||
      GuestUser.new
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
