class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  
  def new # implicitly renders app/views/users/new.html.erb view file
    @user = User.new
  end

  def create
  end

  def show
    render show_template # private method #show_template returns string name of view file to be rendered
  end

  def edit
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def show_template # this method returns the string name of the show template to render, which depends on the user's role
      set_user # calling private method defined above
      case set_user.role
      when set_user.unassigned_user?
        "unassigned_user"
      when set_user.patient?
        "patient"
      when set_user.therapist?
        "therapist"
      when set_user.admin?
        "admin"
      end
      "#{set_user.role}_#{action_name}"
    end

    def user_params
      params.require(:user).permit(
        :name,
        :email,
        :password,
        :password_confirmation,
        :uid,
        :twitter_handle,
        :bio,
        :severity,
        :role,
        :role_requested
      )
    end
end
