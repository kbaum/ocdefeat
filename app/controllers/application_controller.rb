class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :login_required, except: [:new, :create, :home, :privacy, :terms]

  private

    def plural_inflection(collection)
      case collection
      when @filtered_users
        "#{@filtered_users.count} #{'patient'.pluralize(@filtered_users.count)}"
      when @obsessions
        "#{@obsessions.count} #{'obsession'.pluralize(@obsessions.count)}"
      when @plans
        "#{@plans.count} ERP #{'plan'.pluralize(@plans.count)}"
      end
    end

    def sv_agreement(collection)
      case collection
      when @filtered_users # returns string such as "1 patient is" or "2 patients are"
        "#{@filtered_users.count} #{'patient'.pluralize(@filtered_users.count)} #{'is'.pluralize(@filtered_users.count)}"
      when @obsessions # returns string such as "1 obsession is" or "2 obsessions are"
        "#{@obsessions.count} #{'obsession'.pluralize(@obsessions.count)} #{'is'.pluralize(@obsessions.count)}"
      when @plans # returns string such as "1 ERP plan is" or "2 ERP plans are"
        "#{@plans.count} ERP #{'plan'.pluralize(@plans.count)} #{'is'.pluralize(@plans.count)}"
      end
    end

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

    def filters
      if controller_name == "users" # we're in the UsersController, so we want to filter users
        policy_scope(Filter).delete_if {|filter_object| filter_object.filtered != "users"}.first
      elsif controller_name == "plans" # we're in the PlansController,so we want to filter plans
        policy_scope(Filter).delete_if {|filter_object| filter_object.filtered != "plans"}.first
      elsif controller_name == "obsessions" # we're in the ObsessionsController, so we want to filter obsessions
        policy_scope(Filter).delete_if {|filter_object| filter_object.filtered != "obsessions"}.first
      end
    end
    # Explanation of #filters:
    # When a therapist is viewing the users index, #filters returns this:
    #<Filter:0x007fcfd4fb88e8 @filterer="therapist", @filtered="users">
    # In app/views/users/index.html.erb partial, I <%= render partial: filters ... %>
    # Since #filters returns a filter instance, ActionPack uses the custom #to_partial_path method that I defined in Filter model
    # #to_partial_path called on the filter instance returns the string name of the partial that will be rendered
    # In this case, it returns the string "filter_users/therapist"
    # We're rendering app/views/filter_users/_therapist.html.erb partial from the users index page
    helper_method :current_user, :logged_in?, :filters # makes methods accessible to views
end
