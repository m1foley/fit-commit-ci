class HomeController < ApplicationController
  skip_before_action :require_signin

  def index
  end
end
