class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :login_required, except: [:new, :create, :home]

  private

    def user_not_authorized(exception)
      policy_name = exception.policy.class.to_s.underscore
      flash[:alert] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
      redirect_to(request.referrer || root_path)
    end

    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def logged_in?
      !!current_user # the truthiness of calling #current_user
    end

    def login_required # redirect to the homepage unless the user is logged in
      redirect_to root_path unless logged_in?
    end

    def filter
      if controller_name == "users" # we want to filter users
        policy_scope(Filter).delete_if {|filter_object| filter_object.filtered == "obsessions" || filter_object.filtered == "plans"}
      elsif controller_name == "plans" # we want to filter plans
        policy_scope(Filter).delete_if {|filter_object| filter_object.filtered == "users" || filter_object.filtered == "obsessions"}
      elsif controller_name == "obsessions" # we want to filter obsessions
        policy_scope(Filter).delete_if {|filter_object| filter_object.filtered == "users" || filter_object.filtered == "plans"}
      end
    end

  helper_method :current_user, :logged_in? # makes methods accessible to views
end
