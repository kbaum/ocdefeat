class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def new # implicitly renders app/views/users/new.html.erb view file
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id # log in the user
      redirect_to user_path(@user), notice: "You successfully registered and created your preliminary profile, #{current_user.name}!"
    else
      flash.now[:error] = "Your registration attempt was unsuccessful. Please try again."
      render :new # present the registration form so the user can try signing up again
    end
  end

  def show
    render show_template # private method #show_template returns string name of view file to be rendered
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "User information was successfully updated!"
    else
      flash.now[:error] = "Your attempt to edit user information was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy
    @user.destroy
    if current_user.unassigned_user?
      redirect_to root_path, notice: "Your preliminary profile was successfully deleted."
    elsif current_user.patient?
      redirect_to root_path, notice: "We hope that your experience with OCDefeat was productive and meaningful, and that you have acquired the skillset necessary to defeat OCD!"
    elsif current_user.therapist?
      redirect_to root_path, notice: "We hope that your experience working as an OCDefeat Therapy Forum Facilitator was rewarding. Thank you for helping our patients defeat OCD!"
    elsif current_user.admin?
      redirect_to users_path, notice: "The user's account was successfully deleted."
    end
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
