require "test_helper"

class GuestUserTest < ActiveSupport::TestCase
  test "is not logged in" do
    guest_user = GuestUser.new
    assert !guest_user.logged_in?
  end
end
