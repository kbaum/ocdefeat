class UsersController < ApplicationController
  def new # implicitly renders app/views/users/new.html.erb view file
    @user = User.new
  end

  def create
  end

  def show
  end

  private

    def set_user
      @user = User.find(params[:id])
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
