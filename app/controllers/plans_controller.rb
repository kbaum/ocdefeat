class PlansController < ApplicationController
  before_action :prepare_plan, only: [:show, :edit, :update, :destroy]
  before_action :set_obsessions, only: [:index]
  before_action :require_plans, only: [:index]
  before_action :preserve_plan, only: [:edit, :update]

  def index
    plans = policy_scope(Plan)
    @counselees = policy_scope(User) # used in app/views/filter_plans/_therapist.html.erb to store AR::Relation of the patients (counselees) that the therapist was assigned
    @themes = policy_scope(Theme) # Theme.all - patients, therapists and admins can view all themes

    if current_user.patient?
      if !params[:title].blank? # Patient filters her own plans by title -- params[:title] stores ID of plan selected by title from dropdown menu
        @plans = plans.find(params[:title])
        flash.now[:notice] = "An overview of the ERP plan entitled \"#{@plans.title}\" is displayed below!"
      elsif !params[:obsession_targeted].blank? # Patient filters her own plans by the obsession targeted -- params[:obsession_targeted] is the ID of obsession for which the patient searches plans
        thought = current_user.obsessions.find(params[:obsession_targeted]).intrusive_thought
        if current_user.obsessions.find(params[:obsession_targeted]).plans.empty? # If no plans for the selected obsession were found
          flash.now[:alert] = "No ERP plans target the obsession: \"#{thought}\""
        else
          @plans = current_user.obsessions.find(params[:obsession_targeted]).plans # stores AR::Relation of plans belonging to the obsession selected
          flash.now[:notice] = "You can implement #{plural_inflection(@plans)} to expose yourself to the obsession: \"#{thought}\""
        end
      else # Patient did not choose a filter, so @plans stores AR::Relation of only plans designed by the patient
        @plans = plans
        flash.now[:notice] = "You designed #{plural_inflection(@plans)} to expose yourself to your obsessions."
      end
    elsif current_user.therapist?
      if !params[:designer].blank? # Therapist filters plans by patient designer -- params[:designer] is the ID of the user whose plans we want to find
        if plans.designed_by(params[:designer]).empty? # If the selected user did not design any plans
          flash.now[:alert] = "No ERP plans were designed by patient #{@counselees.find(params[:designer]).name}."
        else
          @plans = plans.designed_by(params[:designer])
          flash.now[:notice] = "You found #{plural_inflection(@plans)} designed by patient #{@plans.first.user.name}!"
        end
      elsif !params[:subset].blank? # Therapist filters plans by OCD subset -- params[:subset] is the ID of the theme
        if plans.by_subset(params[:subset]).empty? # If no plans are classified in the selected OCD subset
          flash.now[:alert] = "None of your patients' ERP plans target obsessions that revolve around \"#{Theme.find(params[:subset]).name}.\""
        else
          @plans = plans.by_subset(params[:subset]) # stores AR::Relation of plans that thematically relate to the selected subset
          flash.now[:notice] = "#{plural_inflection(@plans)} will help your patients confront obsessions about \"#{Theme.find(params[:subset]).name}.\""
        end
      elsif !params[:patient_planner].blank? # Therapist filters plans by patient's stepless plans
        patient_name = @counselees.find(params[:patient_planner]).name
        if @counselees.find(params[:patient_planner]).plans.empty? # If the selected patient has no ERP plans
          flash.now[:alert] = "No ERP plans were designed by patient #{patient_name}."
        elsif @counselees.find(params[:patient_planner]).plans.stepless.empty? # The patient has plans, but all of these plans have steps
          flash.now[:alert] = "All plans designed by patient #{patient_name} contain steps."
        else # The patient has plans without steps
          @plans = @counselees.find(params[:patient_planner]).plans.stepless
          flash.now[:notice] = "Patient #{patient_name} must add exposure exercises to #{plural_inflection(@plans)}!"
        end
      elsif !params[:patient_progressing].blank? # Therapist filters plans by patient's progress toward plan completion -- params[:patient_progressing] is the ID of the user
        patient_progressing = @counselees.find(params[:patient_progressing])
        if patient_progressing.obsessions.empty? # If the selected patient has no obsessions
          flash.now[:alert] = "No ERP plans were found for patient #{patient_progressing.name}, but that's okay because this patient is not obsessing!"
        elsif patient_progressing.plans.empty? # If the selected patient has obsessions but no ERP plans
          flash.now[:alert] = "Patient #{patient_progressing.name} should design ERP plans to overcome obsessions."
        else # If the patient has plans
          @done = patient_progressing.plans.accomplished if !patient_progressing.plans.accomplished.empty?
          @undone = patient_progressing.plans.unaccomplished if !patient_progressing.plans.unaccomplished.empty?
          flash.now[:notice] = "You retrieved #{patient_progressing.name}'s progress report, which identifies ERP plans that this patient finished and/or left unfinished!"
        end
      else # Therapist did not choose a filter for filtering plans
        @plans = plans # stores all plans designed by the therapist's patients
        flash.now[:notice] = "Collectively, your patients designed #{plural_inflection(@plans)} to gain exposure to their obsessions."
      end # closes logic about filter selected
    elsif current_user.admin?
      if !params[:date].blank? # Admin filters plans by date created
        if params[:date] == "Today"
          if plans.from_today.empty? # If no plans were created today
            flash.now[:alert] = "No ERP plans were designed today."
          else
            @plans = plans.from_today
            flash.now[:notice] = "You found #{plural_inflection(@plans)} designed today!"
          end
        elsif params[:date] == "Past Plans"
          if plans.before_today.empty? # If no plans were created prior to today
            flash.now[:alert] = "No ERP plans were designed before today."
          else
            @plans = plans.before_today
            flash.now[:notice] = "You found #{plural_inflection(@plans)} designed before today!"
          end
        end # closes logic for params[:date]
      elsif !params[:delineation].blank? # Admin filters plans by stepless plans vs. plans delineated with steps
        if params[:delineation] == "Stepless Plans"
          if plans.stepless.empty? # If all plans HAVE steps
            flash.now[:alert] = "All ERP plans have at least one step."
          else
            @plans = plans.stepless # stores AR::Relation of stepless plans
            flash.now[:notice] = "#{sv_agreement(@plans)} lacking steps!"
          end
        elsif params[:delineation] == "Plans with Steps"
          if plans.with_steps.empty? # If no plans have steps
            flash.now[:alert] = "All ERP plans lack steps."
          else
            @plans = plans.with_steps # stores AR::Relation of plans that have at least 1 step
            flash.now[:notice] = "#{sv_agreement(@plans)} populated with steps!"
          end
        end
      elsif !params[:accomplishment].blank? # Admin filters plans by finished/unfinished plans
        if params[:accomplishment] == "Accomplished Plans"
            if plans.accomplished.empty? # If no plans were marked finished
              flash.now[:alert] = "Not a single ERP plan was marked as finished."
            else
              @plans = plans.accomplished # stores AR::Relation of plans marked finished
              flash.now[:notice] = "#{sv_agreement(@plans)} marked finished!"
            end
        elsif params[:accomplishment] == "Unaccomplished Plans"
          if plans.unaccomplished.empty? # If all plans were marked finished
            flash.now[:alert] = "All ERP plans were fully implemented and marked as finished."
          else
            @plans = plans.unaccomplished # stores AR::Relation of unfinished plans
            flash.now[:notice] = "#{sv_agreement(@plans)} left unfinished!"
          end
        end
      else # Admin did not choose a filter for filtering plans
        @plans = plans # stores AR::Relation of all ERP plans designed by all patients
        flash.now[:notice] = "Collectively, patients designed #{plural_inflection(@plans)} to gain exposure to their obsessions."
      end # closes logic about filter selected
    end # closes logic about filterer's role
  end # closes #index action

  def new # Route helper #new_obsession_plan_path(obsession) returns GET "/obsessions/:obsession_id/plans/new"
    @obsession = Obsession.find(params[:obsession_id]) # @obsession is the parent. The form to create a new plan for an obsession is found at: "/obsessions/:obsession_id/plans/new"
    @plan = Plan.new # instance for form_for to wrap around
    authorize @plan
  end

  def create # When the form to create a new plan is submitted, form data is sent via POST request to "/obsessions/:obsession_id/plans"
    @obsession = Obsession.find(params[:obsession_id])
    @plan = @obsession.plans.build(plan_params)
    authorize @plan
    if @plan.save
      redirect_to plan_path(@plan), notice: "You successfully created the ERP plan entitled #{@plan.title}!"
    else
      flash.now[:error] = "Your attempt to create a new ERP plan was unsuccessful. Please try again."
      render :new
    end
  end

  def show
    authorize @plan
    @step = Step.new # instance for form_for to wrap around in nested resource form on plan show page
    @plan_steps = @plan.steps # @plan_steps stores array of all steps belonging to @plan
  end

  def edit
    authorize @plan
    @obsession = @plan.obsession
  end

  def update # PATCH or PUT request to "/plans/:id" maps to plans#update
    authorize @plan

    if @plan.update_attributes(permitted_attributes(@plan))
      if @plan.finished? # If the plan is updated from unfinished (progress = 0) to finished (progress = 1)
        redirect_to plan_path(@plan), notice: "Congratulations on developing anxiety tolerance by finishing this ERP plan!"
      else
        redirect_to plan_path(@plan), notice: "An overview of this ERP plan was successfully updated!"
      end
    else
      flash.now[:error] = "Your attempt to edit this ERP plan was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy
    authorize @plan
    @plan.destroy
    redirect_to plans_path, notice: "ERP plan was successfully deleted!"
  end

  private
    def preserve_plan
      @plan = Plan.find(params[:id])
      if @plan.finished?
        redirect_to plan_path(@plan), alert: "You already accomplished and archived this ERP plan!"
      end
    end

    def prepare_plan
      @plan = Plan.find(params[:id])
    end

    def require_plans # private method called before plans#index
      plans = policy_scope(Plan)
      if plans.empty?
        if current_user.admin?
          redirect_to root_path, alert: "The Index of ERP plans is currently empty."
        elsif current_user.therapist?
          redirect_to users_path, alert: "ERP plans designed by your patients were not found."
        elsif current_user.patient?
          if current_user.obsessions.empty? # If the user has no plans but also has no obsessions
            redirect_to user_path(current_user), alert: "Looks like you're not implementing any ERP plans, but that's okay since you're not obsessing!"
          else # the patient has obsessions for which no plans were designed
            first_planless_obsession = current_user.obsessions.sans_plans.first
            redirect_to new_obsession_plan_path(first_planless_obsession), alert: "Looks like you're obsessing and need to implement some exposure exercises. Why not design a new ERP plan for this obsession now?"
          end
        end
      end
    end



    def set_obsessions
      if current_user.patient?
        @your_obsessions = current_user.obsessions
        if @your_obsessions.empty?
          redirect_to new_obsession_path, alert: "No ERP plans were found since you have no obsessions. Create an obsession now?"
        else
          @your_obsessions
        end
      end
    end

    def plan_params
      params.require(:plan).permit(
        :title,
        :goal,
        :flooded,
        :obsession_id,
        :progress
      )
    end
end
