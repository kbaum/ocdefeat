class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  private

    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def logged_in?
      !!current_user # the truthiness of calling #current_user
    end

  helper_method :current_user, :logged_in? # makes methods accessible to views
end
