class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :login_required, except: [:new, :create, :home]

  private

    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def logged_in?
      !!current_user # the truthiness of calling #current_user
    end

    def login_required # redirect to the homepage unless the user is logged in
      redirect_to root_path unless logged_in?
    end

  helper_method :current_user, :logged_in? # makes methods accessible to views
end
