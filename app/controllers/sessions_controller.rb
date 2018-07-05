class SessionsController < ApplicationController
  skip_before_action :login_required, only: [:new, :create]
  before_action :prevent_logged_in_users_from_viewing_login, only: [:new]

  def new # implicitly renders app/views/sessions/new.html.erb (login form template)
  end

  def create # receives data submitted in login form, authenticates and logs in a valid user
    if auth_hash = request.env["omniauth.auth"]
      @user = User.find_or_create_by_omniauth(auth_hash)
      session[:user_id] = @user.id
      redirect_to user_path(@user), flash: { success: "You successfully logged in!" }
    else
      @user = User.find_by(email: params[:email])
      if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id # log in the user
        redirect_to user_path(@user), flash: { success: "You successfully logged in! Welcome back to OCDefeat, #{@user.name}!" }
      else # present login form so user can try logging in again
        flash.now[:error] = "Your login attempt was unsuccessful. Please enter a valid email and password combination."
        render :new
      end
    end
  end

  def destroy # logging out the user
    session.clear # session[:user_id] = nil
    redirect_to root_url, flash: { success: "Thanks for using OCDefeat! Goodbye for now." }
  end

  private

    def prevent_logged_in_users_from_viewing_login
      redirect_to root_path, alert: "You cannot view the login form since you're already logged in!" if current_user
    end
end

# If the user is trying to log into my app via Facebook,
# auth_hash["provider"] is "twitter"
# auth_hash["uid"] is the user's ID on twitter
# auth_hash["info"]["name"] = "Jenna Leopold"
# auth_hash["info"]["nickname"] = "code_snippet_JL"
# auth_hash["info"]["description"] = "build code, break code, ad infinitum"
# auth_hash["info"]["location"] = "Westfield, NJ"
