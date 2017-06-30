require "test_helper"

class SignedInUserTest < ActiveSupport::TestCase
  test "is signed in" do
    signed_in_user = SignedInUser.new(Object.new)
    assert signed_in_user.signed_in?
  end

  test "delegates to the decorated object" do
    signed_in_user = SignedInUser.new(Struct.new(:foo).new(1))
    assert_equal 1, signed_in_user.foo
  end

  test "doesn't find an existing user if token is nil" do
    assert_nil SignedInUser.get(nil)
  end

  test "doesn't find an existing user if token is not found" do
    assert_nil SignedInUser.get("nonexistent token")
  end

  test "finds an existing user when the token is found" do
    user = users(:alice)
    assert_equal user.id, SignedInUser.get(user.remember_token).id
  end
end
