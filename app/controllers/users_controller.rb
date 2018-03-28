class UsersController < ApplicationController
  def new # implicitly renders app/views/users/new.html.erb view file
    @user = User.new
  end

  def create
  end

  private

    def user_params
      params.require(:user).permit(
        :name,
        :email,
        :password,
        :password_confirmation,
        :uid,
        :severity,
        :role,
        :role_requested
      )
    end
end
