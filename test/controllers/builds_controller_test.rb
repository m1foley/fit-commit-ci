require "test_helper"

class BuildsControllerTest < ActionDispatch::IntegrationTest
  def test_confirmation_ping
    post builds_url, params: { payload: "{\"zen\":\"foo\"}" }
    assert_response :success
  end
end
