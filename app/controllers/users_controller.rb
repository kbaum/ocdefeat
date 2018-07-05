class UsersController < ApplicationController
  skip_before_action :login_required, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :deletion_msg, only: [:destroy]
  before_action :reset_role_requested, only: [:edit, :update]
  before_action :require_users, only: [:index]
  before_action :prevent_signed_in_users_from_viewing_signup, only: [:new]

  def index # implicitly renders app/views/users/index.html.erb (where #filter method will be called to determine what the users index looks like depending on the current user's role and the filtered objects they're permitted to see)
    users = policy_scope(User)
    @themes = policy_scope(Theme)
    @treatments = Treatment.all

    if current_user.therapist? # A therapist sees her own patients on the users index page
      @filtered_users = PatientFinder.new(users).call(therapist_filters_patients_params)
      @symptomatic_patients = users.symptomatic
      @asymptomatic_nonobsessive_patients = users.patients_nonobsessive
      @asymptomatic_obsessive_patients = users.patients_obsessive_but_symptomless
      @patients_with_planless_obsession = users.with_planless_obsession
      @patients_planning_or_practicing_erp = users.patients_planning_or_practicing_erp
      @patients_with_finished_plan = users.with_finished_plan
    elsif current_user.admin?
      @patients_without_counselor = User.patients_uncounseled
      @therapists = User.by_role("therapist")
      @table_users = users # stores AR::Relation of all user instances
      @prospective_patients = users.awaiting_assignment(%w(Therapist Admin), 1)
      @therapists_to_be = users.awaiting_assignment(%w(Patient Admin), 2)
      @aspiring_admins = users.awaiting_assignment(%w(Patient Therapist), 3)

      if !params[:role].blank? # Admin filters users by role ("unassigned", "patient", "therapist" or "admin")
        if users.by_role(params[:role]).empty? # If there are no users with the selected role
          flash.now[:alert] = "No users were found."
        else # If users with the selected role were found
          @filtered_users = users.by_role(params[:role]) # stores AR::Relation of users with the selected role
          flash.now[:success] = "You found #{@filtered_users.count} #{params[:role]} #{'user'.pluralize(@filtered_users.count)}!"
        end
      else
        @filtered_users = users # Admin did not choose a filter, so @filtered_users stores all users
      end
    #elsif current_user.therapist? # When therapist views users index page, users variable stores the therapist's patients
      #if !params[:severity_and_variant].blank? # Therapist filters by specific OCD severity ("Mild", "Moderate", "Severe", "Extreme") and variant of OCD ("Traditional", "Purely Obsessional", "Both")
        #severity = params[:severity_and_variant].split(" and ").first
        #variant = params[:severity_and_variant].split(" and ").last
        #if users.by_severity_and_variant(severity, variant).empty?
          #flash.now[:alert] = "None of your patients have #{severity.downcase} OCD and #{variant.downcase} types of compulsions."
        #else
          #@filtered_users = users.by_severity_and_variant(severity, variant) # stores AR::Relation of therapist's patients with a specific OCD severity and variant combination
          #flash.now[:notice] = "You found #{plural_inflection(@filtered_users)} with #{severity.downcase} OCD and #{variant.downcase} types of compulsions!"
        #end

      #elsif !params[:theme_preoccupation].blank? # Find therapist's patients who have at least 1 obsession that's classified in the selected theme
        #if users.obsessing_about(params[:theme_preoccupation]).empty?
          #flash.now[:alert] = "None of your patients' obsessions revolve around \"#{Theme.find(params[:theme_preoccupation]).name}.\""
        #else
          #@filtered_users = users.obsessing_about(params[:theme_preoccupation])
          #flash.now[:notice] = "#{sv_agreement(@filtered_users)} preoccupied with \"#{Theme.find(params[:theme_preoccupation]).name}.\""
        #end
      #elsif !params[:symptoms_presence].blank? # Therapist filters patients by symptomatic/asymptomatic patients
        #if users.all? {|user| user.obsessions.empty?} # If none of the therapist's patients have obsessions
          #flash.now[:notice] = "All of your patients are asymptomatic since none of them are obsessing!"
        #elsif params[:symptoms_presence] == "Symptomatic patients"
          #if users.symptomatic.empty?
            #flash.now[:alert] = "None of your patients present with physical symptoms of OCD."
          #else
            #@filtered_users = users.symptomatic
            #flash.now[:notice] = "#{sv_agreement(@filtered_users)} physically symptomatic of OCD."
          #end
        #elsif params[:symptoms_presence] == "Asymptomatic patients"
          #if users.patients_nonobsessive.empty? && users.patients_obsessive_but_symptomless.empty?
            #flash.now[:alert] = "All of your patients present with physical symptoms of OCD."
          #else

            #total_asymptomatic = users.count - users.symptomatic.count
            #flash.now[:notice] = "You have #{total_asymptomatic} #{'asymptomatic patient'.pluralize(total_asymptomatic)}!"
          #end
        #end
      #elsif !params[:recent_ruminators].blank? # Therapist filters patients by those who reported new obsessions yesterday or today
        #if users.ruminating_yesterday.empty? && users.ruminating_today.empty?
          #flash.now[:alert] = "None of your patients reported new obsessions yesterday or today."
        #elsif params[:recent_ruminators] == "Patients who reported new obsessions yesterday"
          #if users.ruminating_yesterday.empty?
            #flash.now[:alert] = "None of your patients reported new obsessions yesterday."
          #else
            #@filtered_users = users.ruminating_yesterday
            #flash.now[:notice] = "#{plural_inflection(@filtered_users)} reported new obsessions yesterday!"
          #end
        #elsif params[:recent_ruminators] == "Patients who reported new obsessions today"
          #if users.ruminating_today.empty?
            #flash.now[:alert] = "None of your patients reported new obsessions today."
          #else
            #@filtered_users = users.ruminating_today
            #flash.now[:notice] = "#{plural_inflection(@filtered_users)} reported new obsessions today!"
          #end
        #end
      #else
        #@filtered_users = users # stores AR::Relation of therapist's patients if no filter was applied when therapist views page
      #end
    elsif current_user.patient?
      @therapists = users # @therapists stores AR::Relation of all therapists when patient views users index page
      flash.now[:notice] = "#{@therapists.count} #{'therapist'.pluralize(@therapists.count)} #{'is'.pluralize(@therapists.count)} available to guide you on your journey to defeat OCD!"
    end
  end

  def new
    @user = User.new
    3.times { @user.treatments.build }
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id # log in the user
      redirect_to user_path(@user), flash: { success: "You successfully registered and created your preliminary profile, #{current_user.name}!" }
    else
      flash.now[:error] = "Your registration attempt was unsuccessful. Please try again."
      3.times { @user.treatments.build }
      render :new # present the registration form so the user can try signing up again
    end
  end

  def show
    authorize @user
    render show_template # private method #show_template returns string name of view file to be rendered
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
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
    user = User.find(params[:id])
    authorize user
    user.destroy
    if current_user.admin?
      redirect_to users_path, flash: { success: "The user's account was successfully deleted." }
    else
      redirect_to root_url, flash: { success: @message }
    end
  end

  private

    def therapist_filters_patients_params
      params.permit(
        :severity,
        :variant,
        :theme_fixation,
        :treatment_undergone,
        :recent_ruminators
      )
    end

    def prevent_signed_in_users_from_viewing_signup
      redirect_to root_path, alert: "You cannot view the registration form since you already registered for OCDefeat!" if current_user
    end

    def set_user
      @user = User.find(params[:id])
    end

    def require_users
      users = policy_scope(User)
      if current_user.admin? && users.count == 1
        redirect_to root_path, alert: "Looks like you're all alone. Try to recruit some users to join the OCDefeat community!"
      elsif users.empty?
        if current_user.therapist?
           flash[:alert] = "Looks like you weren't assigned to any patients yet!"
        elsif current_user.patient?
          flash[:alert] = "Unfortunately, no therapists are currently available for counseling."
        end
        redirect_to user_path(current_user)
      end
    end

    def reset_role_requested
      @user = User.find(params[:id])
      if @user.patient? && @user.role_requested.in?(%w[Therapist Admin])
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

    def deletion_msg
      @message =
        case current_user.role
        when "unassigned"
          "Your preliminary profile was successfully deleted."
        when "patient"
          "We hope that your experience with OCDefeat was productive and meaningful, and that you acquired the skillset necessary to defeat OCD!"
        when "therapist"
          "We hope that your experience working as an OCDefeat therapist was rewarding. Thank you for helping our patients defeat OCD!"
        end
    end
end
