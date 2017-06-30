require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

class ActiveSupport::TestCase
  fixtures :all
  OmniAuth.config.test_mode = true
end
