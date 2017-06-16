require "test_helper"

class LoggedInUserTest < ActiveSupport::TestCase
  test "is logged in" do
    logged_in_user = LoggedInUser.new(Object.new)
    assert logged_in_user.logged_in?
  end

  test "delegates to the decorated object" do
    logged_in_user = LoggedInUser.new(Struct.new(:foo).new(1))
    assert_equal 1, logged_in_user.foo
  end
end
