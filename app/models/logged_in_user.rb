class LoggedInUser < SimpleDelegator
  def initialize(user)
    self.user = user
    super
  end

  def logged_in?
    true
  end

  def self.get(current_user_id)
    user = current_user_id && User.find_by(id: current_user_id)
    user && new(user)
  end

  private

  attr_accessor :user
end
