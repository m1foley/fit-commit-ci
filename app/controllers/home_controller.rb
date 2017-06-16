class HomeController < ApplicationController
  skip_before_action :require_login

  def index
    render plain: "home"
  end
end
