class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy]
  before_action :set_obsessions, only: [:index]
  before_action :require_plans, only: [:index]

  def index
    plans = policy_scope(Plan)
    @patients = User.where(role: 1)
    @themes = Theme.all

    if current_user.patient?
      if !params[:title].blank? # Patient filters her own plans by title -- params[:title] stores unique title of plan
        @plans = plans # need patient's own plans for select_tag in app/views/filter_plans/_patient.html.erb
        @plan = current_user.plans.by_title(params[:title])
      elsif !params[:obsession_targeted].blank? # Patient filters her own plans by the obsession targeted -- params[:obsession_targeted] is the ID of obsession for which the patient searches plans
        thought = current_user.obsessions.find(params[:obsession_targeted]).intrusive_thought
        @plans = current_user.obsessions.find(params[:obsession_targeted]).plans
        if @plans.empty? # If no plans for that obsession were found
          flash.now[:alert] = "No ERP plans were found for the obsession \"#{thought}\""
        else
          @plans # stores 'array' of plans belonging to the obsession selected
          flash.now[:notice] = "You found ERP plans targeting the obsession \"#{thought}!\""
        end
      else # Patient did not choose a filter, so @plans stores 'array' of only plans designed by the patient
        @plans = plans
      end
    elsif current_user.therapist?
      if !params[:designer].blank? # Therapist filters plans by patient designer -- params[:designer] is the ID of the user whose plans we want to find
        patient_name = @patients.find(params[:designer]).name
        @plans = plans.by_designer(params[:designer])
        if @plans.empty?
          flash.now[:alert] = "No ERP plans were designed by patient #{patient_name}."
        else
          @plans
          flash.now[:notice] = "You found ERP plans designed by patient #{patient_name}!"
        end
      elsif !params[:subset].blank? # Therapist filters plans by OCD subset -- params[:subset] is the ID of the theme
        string_subset = Theme.find(params[:subset]).name
        @plans = plans.by_theme(params[:subset])
        if @plans.empty? # No plans are classified in the selected OCD subset
          flash.now[:alert] = "No ERP plans pertain to '#{string_subset}.'"
        else
          @plans
          flash.now[:notice] = "You found ERP plans pertaining to '#{string_subset}!'"
        end
      elsif !params[:patient_planning].blank? # Therapist filters plans by patient's preliminary plans (plans w/o steps)
        patient_name = @patients.find(params[:patient_planning]).name
        if @patients.find(params[:patient_planning]).plans.empty? # the patient selected has no ERP plans
          @plans = nil
          flash.now[:alert] = "No ERP plans, including preliminary plans, were designed by patient #{patient_name}."
        elsif @patients.find(params[:patient_planning]).plans.stepless.empty? # the patient has plans, but all of these plans contain steps
          @plans = nil
          flash.now[:alert] = "No preliminary plans were found for #{patient_name}, as all plans designed by this patient contain steps."
        else # the patient has plans without steps
          @plans = plans.stepless
          flash.now[:notice] = "You found preliminary ERP plans designed by #{patient_name}!"
        end
      elsif !params[:patient_progressing].blank? # Therapist filters plans by patient's progress toward plan completion
        patient_progressing = @patients.find(params[:patient_progressing])
        if patient_progressing.plans.empty? # the patient selected has no ERP plans
          @plans = nil
          flash.now[:alert] = "Patient #{patient_progressing.name} must design ERP plans in order to make progress!"
        elsif patient_progressing.plans.with_steps.empty? # the patient has plans, but none of the plans have steps
          @plans = nil
          flash.now[:alert] = "Progress can only be made if plans contain steps! #{patient_progressing.name} should add ERP exercises to each preliminary plan!"
        else # the patient has plans with steps
          if !patient_progressing.plans.completed.empty? # If the patient has completed ERP plans
            @completed = patient_progressing.plans.completed # @completed stores the patient's completed plans
          end

          if !patient_progressing.plans.not_yet_completed.empty? # If the patient has incomplete ERP plans
            @not_yet_completed = patient_progressing.plans.not_yet_completed # @not_yet_completed stores the patient's incomplete plans
          end

          flash.now[:notice] = "You retrieved #{patient_progressing.name}'s ERP progress report, which identifies this patient's completed and/or incomplete ERP plans!"
        end
      else # Therapist did not choose a filter for filtering plans
        @plans = plans
      end # closes logic about filter selected
    elsif current_user.admin?
      if !params[:date].blank? # Admin filters plans by date created
        if params[:date] == "Today"
          @plans = plans.from_today
          if @plans.empty? # If no plans were created today
            flash.now[:alert] = "No ERP plans were created today."
          else
            @plans
            flash.now[:notice] = "You found ERP plans designed today!"
          end
        elsif params[:date] == "Past Plans"
          @plans = plans.past_plans
          if @plans.empty? # If no plans were created prior to today
            flash.now[:alert] = "No ERP plans were created prior to today."
          else
            @plans
            flash.now[:notice] = "You found ERP plans from the past!"
          end
        end # closes logic for params[:date]
      elsif !params[:stepless].blank? # Admin filters plans by preliminary plans (plans without steps)
        @plans = plans.stepless
        if @plans.empty? # all plans HAVE steps
          flash.now[:alert] = "No preliminary plans were found; all ERP plans have at least one step."
        else
          @plans # stores array of all plans without steps
          flash.now[:notice] = "You found preliminary ERP plans, i.e., plans that do not contain steps!"
        end
      elsif !params[:completion].blank? # Admin filters plans by whether or not plan is completed
        if @plans = plans.with_steps.empty? # If NO plans with at least 1 step were found (i.e. all plans have no steps)
          flash.now[:alert] = "ERP plans must have at least one step before assessing status of completion."
        else # Plans with at least 1 step were found
          if params[:completion] == "Completed"
            @plans = plans.completed
            if @plans.empty? # this means that plans with at least 1 step were found, but none of these plans were completed
              flash.now[:alert] = "Completed ERP plans were not found."
            else
              @plans # stores array of completed plans (each containing at least 1 step)
              flash.now[:notice] = "You successfully found completed ERP plans!"
            end
          elsif params[:completion] == "Not Yet Completed"
            @plans = plans.not_yet_completed
            if @plans.empty? # plans with at least 1 step were found, but these plans were completed
              flash.now[:alert] = "Unfinished ERP plans were not found."
            else
              @plans # stores array of incomplete plans (each containing at least 1 step)
              flash.now[:notice] = "You successfully found ERP plans that are not yet completed!"
            end
          end # closes logic starting with if params[:completion] == "Completed"
        end # closes logic from if @plans = plans.with_steps.empty?
      else # Admin did not choose a filter for filtering plans
        @plans = plans
      end # closes logic about filter selected
    end # closes logic about filterer's role
  end # closes #index action

  def new
    if current_user.patient? && current_user.obsessions.empty?
      redirect_to new_obsession_path, alert: "You currently have no obsessions! You must first create an obsession before designing an ERP plan in which to tackle that obsession!"
    else
      @plan = Plan.new # instance for form_for to wrap around
      authorize @plan
    end
  end

  def create
    @plan = Plan.new(plan_params)
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
  end

  def update
    authorize @plan
    if @plan.update(plan_params)
      redirect_to plan_path(@plan), notice: "This ERP plan was successfully updated!"
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

    def set_plan
      @plan = Plan.find(params[:id])
    end

    def require_plans # private method called before plans#index
      plans = policy_scope(Plan)
      # When viewer is admin/therapist, plans = Plan.all (all ERP plans designed by all patients)
      # when viewer is patient, plans stores 'array' of only that patient's plans
      if current_user.admin? || current_user.therapist?
        if plans.empty?
          redirect_to user_path(current_user), alert: "The index of all patients' ERP plans is empty."
        end
      elsif current_user.patient?
        if plans.empty?
          redirect_to new_plan_path, alert: "Looks like you didn't desensitize lately! Your index of ERP plans is currently empty."
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
        :obsession_id
      )
    end
end
