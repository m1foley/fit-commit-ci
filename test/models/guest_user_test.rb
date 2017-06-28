require "test_helper"

class GuestUserTest < ActiveSupport::TestCase
  it "is not logged in" do
    guest_user = GuestUser.new
    assert !guest_user.logged_in?
  end
end
