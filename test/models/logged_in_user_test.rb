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

  test "doesn't find an existing user if token is nil" do
    assert_nil LoggedInUser.get(nil)
  end

  test "doesn't find an existing user if token is not found" do
    assert_nil LoggedInUser.get("nonexistent token")
  end

  test "finds an existing user when the token is found" do
    user = User.create!(username: "gu", remember_token: "rtok1")
    assert_equal user.id, LoggedInUser.get("rtok1").id
  end
end
