class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_user

  private

  def current_user
    @current_user ||= session[:current_user_id] &&
      User.find_by(id: session[:current_user_id])
  end

  def require_user
    return if current_user
    render text: "not logged in"
    throw(:abort)
  end
end
