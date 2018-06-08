class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :deletion_msg, only: [:destroy]

  def index # implicitly renders app/views/users/index.html.erb (where #filter method will be called to determine what the users index looks like depending on the viewer's role and the filtered objects they're permitted to see)
    users = policy_scope(User) # we're filtering users - users stores the array of user instances available to the type of viewer
    # when an admin views the users index, @users stores 'array' of ALL user instances (for the table)
    # when a therapist views the users index, @users stores 'array' of only patients
    # when a patient views the users index, @users stores 'array' of only therapists (like directory w/ contact info)

    # From an admin's perspective, the users index page presents a table to manage all users accounts, i.e.,
    # change users' roles, delete accounts. There is also 1 filter to filter users by current role
    # The first 4 instance variables below correspond to locals used in app/views/filter_users/_admin.html.erb partial (which is rendered on users index pg when admin is viewer)
    if current_user.admin?
      @table_users = users # @table_users stores array of all user instances
      @filtered_users = users
      @prospective_patients = users.awaiting_assignment(%w(Therapist Admin), 1)
      @therapists_to_be = users.awaiting_assignment(%w(Patient Admin), 2)
      @aspiring_admins = users.awaiting_assignment(%w(Patient Therapist), 3)

      if !params[:role].blank? # Admin filters users by role ("unassigned", "patient", "therapist" or "admin")
        if users.by_role(params[:role]).empty? # If there are no users with the selected role
          if params[:role] == "unassigned"
            flash.now[:alert] = "No unassigned users were found."
          else
            flash.now[:alert] = "No #{params[:role]}s were found."
          end
        else # If users with the selected role were found
          @filtered_users = users.by_role(params[:role]) # stores 'AR::Relation' of all users with the selected role
          if params[:role] == "unassigned"
            flash.now[:notice] = "#{@filtered_users.count} #{"user".pluralize(@filtered_users.count)} #{'is'.pluralize(@filtered_users.count)} not yet assigned a role."
          else
            flash.now[:notice] = "You found #{@filtered_users.count} #{params[:role].pluralize(@filtered_users.count)}!"
          end
        end
      else
        @filtered_users = users # Admin did not choose a filter, so @filtered_users stores all users
      end
    elsif current_user.therapist? # When therapist views users index page, users variable stores all patients
      if !params[:severity].blank? # Therapist filters patients by OCD severity
        if users.by_ocd_severity(params[:severity]).empty? # If no patients have the selected OCD severity
          flash.now[:alert] = "No patients were diagnosed with #{params[:severity]} OCD."
        else
          @filtered_users = users.by_ocd_severity(params[:severity]) # stores AR::Relation of all patients with the selected OCD severity
          flash.now[:notice] = "#{sv_agreement(@filtered_users)} diagnosed with #{params[:severity]} OCD!"
        end
      elsif !params[:variant].blank? # Therapist filters patients by OCD variant
        if users.by_ocd_variant(params[:variant]).empty? # If no patients have the specified OCD variant
          flash.now[:alert] = "No patients with that variant of OCD were found."
        else
          @filtered_users = users.by_ocd_variant(params[:variant]) # stores AR::Relation of all patients with a specific OCD variant
          if params[:variant] == "Both"
            flash.now[:notice] = "#{sv_agreement(@filtered_users)} both traditionally and purely obsessive."
          elsif params[:variant] == "Purely Obsessional"
            flash.now[:notice] = "#{sv_agreement(@filtered_users)} purely obsessive."
          else
            flash.now[:notice] = "#{sv_agreement(@filtered_users)} traditionally obsessive."
          end
        end
      elsif !params[:severity_and_variant].blank? # Therapist filters by specific OCD severity ("Mild", "Moderate", "Severe", "Extreme") and variant of OCD ("Traditional", "Purely Obsessional", "Both")
        severity = params[:severity_and_variant].split(" and ").first
        variant = params[:severity_and_variant].split(" and ").last
        if users.by_severity_and_variant(severity, variant).empty?
          flash.now[:alert] = "There are no patients with #{severity.downcase} OCD and #{variant.downcase} types of compulsions."
        else
          @filtered_users = users.by_severity_and_variant(severity, variant) # stores AR::Relation of all patients with a specific OCD severity and variant combination
          flash.now[:notice] = "You found #{plural_inflection(@filtered_users)} with #{severity.downcase} OCD and #{variant.downcase} types of compulsions!"
        end
      elsif !params[:desensitization_degree].blank? # Therapist filters patients by degree of desensitization
        if users.all? {|user| user.obsessions.empty?} # If no patient is obsessing about anything at all
          flash.now[:alert] = "No patients are obsessing, so there is no need to develop desensitization through repeated exposure exercises."
        elsif params[:desensitization_degree] == "Not Desensitized" # Therapist filters by patients who have at least 1 obsession for which no ERP plans were designed
          if users.unexposed_to_obsession.empty?
            flash.now[:alert] = "Patients are developing anxiety tolerance and may have become desensitized to their obsessions! No obsessions lack ERP plans!"
          else
            @filtered_users = users.unexposed_to_obsession
            flash.now[:notice] = "#{sv_agreement(@filtered_users)} not fully desensitized to obsessions, having reported at least one obsession that lacks ERP plans."
          end
        elsif params[:desensitization_degree] == "Developing Desensitization Plans" # Therapist filters patients by those with at least 1 preliminary ERP plan (i.e. plan that lacks steps)
          if users.patients_planning_preliminarily.empty?
            flash.now[:alert] = "No patients designed preliminary ERP plans, i.e., plans sans steps."
          else
            @filtered_users = users.patients_planning_preliminarily # stores AR::Relation of patients who have preliminary ERP plans
            flash.now[:notice] = "#{plural_inflection(@filtered_users)} designed at least one preliminary ERP plan."
          end
        elsif params[:desensitization_degree] == "Deficient ERP Plan Performance" # Therapist filters patients by those who have at least 1 unfinished ERP plan
          if users.patients_planning.empty?
            flash.now[:alert] = "Patients are not implementing ERP plans; the Index of ERP Plans is currently empty."
          elsif users.patients_with_populated_plan.empty?
            flash.now[:alert] = "Patients have only brainstormed the titles and goals of ERP plans. An ERP plan must contain a step-by-step procedure before its status of completion can be determined."
          elsif users.patients_with_unfinished_plan.empty?
            flash.now[:alert] = "Patients proficiently performed all ERP plans; no plans were left unfinished."
          else
            @filtered_users = users.patients_with_unfinished_plan
            flash.now[:notice] = "You found #{plural_inflection(@filtered_users)} with at least one unfinished ERP plan."
          end
        elsif params[:desensitization_degree] == "Done Desensitizing" # Therapist filters patients by those who have obsessions, who have NO obsessions that lack ERP plans, and whose ERP plans are all finished
          if users.patients_fully_desensitized.empty?
            flash.now[:alert] = "No patient is fully desensitized to all OCD triggers."
          else
            @filtered_users = users.patients_fully_desensitized
            flash.now[:notice] = "#{sv_agreement(@filtered_users)} fully desensitized to OCD triggers, having implemented an ERP plan for each obsession!"
          end
        end
      elsif !params[:symptoms_presence].blank? # Therapist filters patients by symptomatic/asymptomatic patients
        if users.all? {|user| user.obsessions.empty?} # If none of the patients have obsessions
          flash.now[:notice] = "All patients are asymptomatic since nobody is obsessing!"
        elsif params[:symptoms_presence] == "Symptomatic patients"
          if users.symptomatic.empty?
            flash.now[:alert] = "No patients present with physical symptoms of OCD."
          else
            @filtered_users = users.symptomatic
            flash.now[:notice] = "#{sv_agreement(@filtered_users)} physically symptomatic of OCD."
          end
        elsif params[:symptoms_presence] == "Asymptomatic patients"
          if users.asymptomatic.empty?
            flash.now[:alert] = "All patients with obsessions present with physical symptoms of OCD."
          else
            @filtered_users = users.asymptomatic
            flash.now[:notice] = "#{sv_agreement(@filtered_users)} asymptomatic."
          end
        end
      elsif !params[:recent_ruminators].blank? # Therapist filters patients by those who reported new obsessions yesterday or today
        if users.ruminating_yesterday.empty? && users.ruminating_today.empty?
          flash.now[:alert] = "No patients reported new obsessions yesterday or today."
        elsif params[:recent_ruminators] == "Patients who reported new obsessions yesterday"
          if users.ruminating_yesterday.empty?
            flash.now[:alert] = "No patients reported new obsessions yesterday."
          else
            @filtered_users = users.ruminating_yesterday
            flash.now[:notice] = "#{plural_inflection(@filtered_users)} reported new obsessions yesterday!"
          end
        elsif params[:recent_ruminators] == "Patients who reported new obsessions today"
          if users.ruminating_today.empty?
            flash.now[:alert] = "No patients reported new obsessions today."
          else
            @filtered_users = users.ruminating_today
            flash.now[:notice] = "#{plural_inflection(@filtered_users)} reported new obsessions today!"
          end
        end
      elsif !params[:num_obsessions].blank? # Therapist filters patients by obsession count
        if users.all? {|user| user.obsessions.empty?} # If no patient has obsessions
          flash.now[:alert] = "Not a single patient has obsessions!"
        else # Patients have obsessions
          first_obsession_count = users.first.obsession_count
          if users.count == 1 # If there is only 1 patient
            @filtered_users = users # AR::Relation containing 1 user instance
            flash.now[:notice] = "A single patient was found who has #{first_obsession_count} #{'obsession'.pluralize(first_obsession_count)}!"
          elsif users.all? {|user| user.obsession_count == first_obsession_count} # > 1 patient, but all patients have the same number of obsessions
            flash.now[:alert] = "Patients cannot be ordered by number of obsessions, as all patients reported #{first_obsession_count} #{'obsession'.pluralize(first_obsession_count)}!"
          elsif params[:num_obsessions] == "Least to Most Obsessions"
            @filtered_users = users.least_to_most_obsessions # stores AR::Relation of users ordered by those w/ least to most obsessions
            flash.now[:notice] = "Patients are ordered from least to most obsessive!"
          else
            @filtered_users = users.most_to_least_obsessions # stores AR::Relation of users ordered by those w/ most to least obsessions
            flash.now[:notice] = "Patients are ordered from most to least obsessive!"
          end
        end
      else
        @filtered_users = users # @filtered_users stores AR::Relation of all patients if no filter was applied when therapist views page
        flash.now[:notice] = "#{sv_agreement(@filtered_users)} currently seeking your psychological expertise."
      end
    elsif current_user.patient?
      @therapists = users # @therapists stores AR::Relation of all therapists when patient views users index page
      flash.now[:notice] = "#{@therapists.count} #{'therapist'.pluralize(@therapists.count)} #{'is'.pluralize(@therapists.count)} available to guide you on your journey to defeat OCD!"
    end
  end

  def new # implicitly renders app/views/users/new.html.erb view file
    @user = User.new
    3.times { @user.treatments.build }
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
    authorize @user
    if @user.update_attributes(permitted_attributes(@user))
      redirect_to user_path(@user), notice: "User information was successfully updated!"
    else
      flash.now[:error] = "Your attempt to edit user information was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy
    user = User.find(params[:id])
    authorize user
    user.destroy
    redirect_to root_url, notice: @message
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def show_template # this method returns the string name of the show template to render, which depends on the user's role
      set_user # calling private method defined above
      case set_user.role
      when set_user.unassigned?
        "unassigned"
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
        :role_requested,
        :variant,
        :severity,
        :role,
        :treatments_attributes => [:type, :user_treatments => [:duration, :efficacy]]
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
        when "admin"
          "The user's account was successfully deleted."
        end
    end
end
