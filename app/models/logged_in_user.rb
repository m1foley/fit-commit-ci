class LoggedInUser < SimpleDelegator
  def initialize(user)
    self.user = user
    super
  end

  def self.get(remember_token)
    user = remember_token && User.find_by(remember_token: remember_token)
    user && new(user)
  end

  def logged_in?
    true
  end

  private

  attr_accessor :user
end
