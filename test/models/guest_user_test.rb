require "test_helper"

class GuestUserTest < ActiveSupport::TestCase
  def test_is_not_signed_in
    guest_user = GuestUser.new
    assert_not guest_user.signed_in?
  end
end
