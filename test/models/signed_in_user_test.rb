require "test_helper"

class SignedInUserTest < ActiveSupport::TestCase
  def test_is_signed_in
    signed_in_user = SignedInUser.new(Object.new)
    assert signed_in_user.signed_in?
  end

  def test_delegates_to_decorated_object
    signed_in_user = SignedInUser.new(Struct.new(:foo).new(1))
    assert_equal 1, signed_in_user.foo
  end

  def test_nil_token
    assert_nil SignedInUser.get(nil)
  end

  def test_token_not_found
    assert_nil SignedInUser.get("nonexistent token")
  end

  def test_token_found
    user = users(:alice)
    assert_equal user.id, SignedInUser.get(user.remember_token).id
  end
end
