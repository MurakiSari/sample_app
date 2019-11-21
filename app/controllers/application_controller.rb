class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def user_should_have_logged_in
    return if logged_in?

    store_location
    flash[:danger] = "Please login."
    redirect_to login_url
  end
end
