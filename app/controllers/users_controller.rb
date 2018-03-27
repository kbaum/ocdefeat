class UsersController < ApplicationController
  def new # implicitly renders app/views/users/new.html.erb view file
    @user = User.new
  end

  def create
  end
end
