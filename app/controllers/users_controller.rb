class UsersController < ApplicationController
  skip_before_action :login_required, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :reset_role_requested, only: [:update]
  before_action :prevent_users_viewing, only: [:index]

  def index # implicitly renders app/views/users/index.html.erb (where #filter method will be called to determine what the users index looks like depending on the current user's role and the filtered objects they're permitted to see)
    users = policy_scope(User)
    if current_user.therapist? # A therapist sees her own patients on the users index page
      @themes = policy_scope(Theme) # same as Theme.all - Therapist can filter her patients by theme fixation
      @treatments = Treatment.all # Therapist can filter her patients by treatments undergone
      @filtered_users = PatientFinder.new(users).call(therapist_filters_patients_params)
      @symptomatic_patients = users.symptomatic
      @asymptomatic_nonobsessive_patients = users.patients_nonobsessive
      @asymptomatic_obsessive_patients = users.patients_obsessive_but_symptomless
      @patients_with_planless_obsession = users.with_planless_obsession
      @patients_planning_or_practicing_erp = users.patients_planning_or_practicing_erp
      @patients_with_finished_plan = users.with_finished_plan
    elsif current_user.admin?
      @therapists = User.by_role("therapist") # used when admin assigns therapist to a patient
      @prospective_patients = users.awaiting_assignment(%w(Therapist Admin), 1)
      @therapists_to_be = users.awaiting_assignment(%w(Patient Admin), 2)
      @aspiring_admins = users.awaiting_assignment(%w(Patient Therapist), 3)
      if !params[:role].blank? # Admin filters users by role ("unassigned", "patient", "therapist" or "admin")
        if users.by_role(params[:role]).empty? # If there are no users with the selected role
          flash.now[:alert] = "No users were found."
        else # If users with the selected role were found
          @filtered_users = users.by_role(params[:role]) # stores AR::Relation of users with the selected role
          flash.now[:success] = "You found #{@filtered_users.count} #{'user'.pluralize(@filtered_users.count)}!"
        end
      else # Admin did not choose filter, so the table displays data for all user instances
        @filtered_users = users
      end
    elsif current_user.patient?
      @therapists = users # @therapists stores AR::Relation of all therapists when patient views users index page
      flash.now[:notice] = "#{@therapists.count} #{'therapist'.pluralize(@therapists.count)} #{'is'.pluralize(@therapists.count)} available to guide you on your journey to defeat OCD!"
    end
  end

  def new
    @user = User.new # instance for form_for to wrap around
    authorize @user
    3.times { @user.treatments.build }
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id # log in the user
      redirect_to user_path(@user), flash: { success: "You successfully registered and created your preliminary profile, #{current_user.name}!" }
    else
      3.times { @user.treatments.build }
      flash.now[:error] = "Your registration attempt was unsuccessful. Please try again."
      render :new # present the registration form so the user can try signing up again
    end
  end

  def show
    authorize @user # retrieved from before_action :set_user
    @user = @user.decorate # reassign @user to the #<UserDecorator...> object right before rendering user show view
    render show_template # private method #show_template returns string name of view file to be rendered
  end

  def edit
    authorize @user # retrieved from before_action :set_user
  end

  def update
    authorize @user # retrieved from before_action :set_user
    if current_user.admin? && @user.unassigned? && params[:user][:role] != "unassigned"
      if @user.update_attributes(permitted_attributes(@user))
        redirect_to users_path, flash: { success: "#{@user.name} was successfully assigned the role of #{@user.role}!" }
      end
    elsif current_user.admin? && @user.counselor.nil? && !params[:user][:counselor_id].nil?
      if @user.update_attributes(permitted_attributes(@user))
        redirect_to users_path, flash: { success: "Patient #{@user.name} is now under the care of #{User.by_role("therapist").find(params[:user][:counselor_id]).name}!" }
      end
    elsif @user.update_attributes(permitted_attributes(@user))
      redirect_to user_path(@user), flash: { success: "User information was successfully updated!" }
    else
      flash.now[:error] = "Your attempt to edit user information was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy
    authorize @user # retrieved from before_action :set_user
    user_name = @user.name
    @user.destroy
    if current_user.admin?
      redirect_to users_path, flash: { success: "#{user_name}'s account was successfully deleted." }
    else
      redirect_to root_url, flash: { success: "Farewell, #{user_name}. We hope that your experience with OCDefeat was productive and meaningful!" }
    end
  end

  def symptomatic # implicitly renders app/views/users/symptomatic.html.erb
    @your_symptomatic_patients = User.symptomatic.where(counselor: current_user)
  end
  # before_action :confirm_current_user_counselor_with_counselees ensures that: current_user.therapist? && !current_user.counselees.empty?
  private

  def confirm_current_user_counselor_with_counselees
    redirect_to user_path(current_user), alert: "To preserve doctor-patient confidentiality, only therapists who are assigned to patients can evaluate the clinical presentation of OCD in those patients." unless current_user.therapist? && !current_user.counselees.empty?
  end

    def therapist_filters_patients_params
      params.permit(
        :severity,
        :variant,
        :theme_fixation,
        :treatment_undergone,
        :recent_ruminators
      )
    end

    def set_user
      @user = User.find(params[:id])
    end

    def prevent_users_viewing
      if current_user.unassigned? # prevent unassigned users from viewing users index page
        redirect_to user_path(current_user), alert: "An admin must assign your role before you can view the Index of OCDefeat Users."
      elsif current_user.admin? && policy_scope(User).count == 1
        redirect_to root_path, alert: "Looks like you're all alone in the OCDefeat community! There are no accounts to manage."
      elsif policy_scope(User).empty?
        message =
          if current_user.therapist?
            "Looks like you weren't assigned to any patients yet!"
          elsif current_user.patient?
            "Unfortunately, no therapists are available for counseling."
          end
        redirect_to user_path(current_user), alert: "#{message}"
      end
    end

    def reset_role_requested # The user requested the role of therapist/admin but was assigned the role of patient
      @user = User.find(params[:id])
      if @user.patient? && @user.role_requested.in?(%w(Therapist Admin))
        @user.role_requested = "Patient"
        @user.save
      end
    end

    def show_template # this method returns the string name of the show template to render, which depends on the user's role
      user = User.find(params[:id])
      "#{user.role}_#{action_name}"
    end

    def user_params
      params.require(:user).permit(
        :name,
        :email,
        :password,
        :password_confirmation,
        :role_requested,
        :role,
        :severity,
        :variant,
        :counselor_id,
        :treatments_attributes => [:treatment_type, :user_treatments => [:treatment_id, :duration, :efficacy]]
      )
    end
end
