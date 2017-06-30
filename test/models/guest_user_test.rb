require "test_helper"

class GuestUserTest < ActiveSupport::TestCase
  test "is not signed in" do
    guest_user = GuestUser.new
    assert !guest_user.signed_in?
  end
end
