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
        @plans = plans # need plans for select_tag in app/views/filter_plans/_patient.html.erb
        @plan = current_user.plans.by_title(params[:title])
      elsif !params[:obsession_targeted].blank? # Patient filters her own plans by the obsession targeted -- params[:obsession_targeted] is the ID of obsession for which the patient searches plans
        if Obsession.find(params[:obsession_targeted]).plans.empty?
          redirect_to plans_path, alert: "No ERP plans were found for that obsession!"
        else
          @plans = plans.by_obsession(params[:obsession_targeted])
        end
      end
    elsif current_user.therapist?
      if !params[:designer].blank? # Therapist filters plans by patient designer -- params[:designer] is the ID of the user whose plans we want to find
        if plans.by_designer(params[:designer]).empty?
          redirect_to plans_path, alert: "No ERP plans were designed by that patient."
        else
          @plans = plans.by_designer(params[:designer])
        end
      elsif !params[:theme].blank? # Therapist filters plans by OCD theme -- params[:theme] is the ID of the theme
        if plans.by_theme(params[:theme]).empty? # No plans are classified in the selected OCD theme
          redirect_to plans_path, alert: "No ERP plans pertain to this theme."
        else
          @plans = plans.by_theme(params[:theme])
        end
      elsif !params[:patient_planning].blank? # Therapist filters plans by patient's preliminary plans (plans w/o steps)
        @patient_pulled = @patients.find(params[:patient_planning])
        if @patient_pulled.plans.empty? # the patient selected has no ERP plans
          redirect_to plans_path, alert: "No ERP plans, including preliminary plans, were designed by that patient."
        elsif @patient_pulled.plans.stepless.empty? # the patient has plans, but all of these plans contain steps
          redirect_to plans_path, alert: "No preliminary plans were found for that patient, as all plans designed by the patient contain steps."
        else # the patient has plans without steps
          @plans = plans.stepless
        end
      elsif !params[:patient_progressing].blank? # Therapist filters plans by patient's progress toward plan completion
        @patient_picked = @patients.find(params[:patient_progressing])
        if @patient_picked.plans.empty? # the patient selected has no ERP plans
          redirect_to plans_path, alert: "No ERP plans were designed by that patient."
        elsif @patient_picked.plans.with_steps.empty? # the patient has plans, but none of the plans have steps
          redirect_to plans_path, alert: "Progress can only be made if plans contain steps! The patient should add ERP exercises to each preliminary plan!"
        else # the patient has plans with steps
          if !@patient_picked.plans.completed.empty? # The patient has completed ERP plans
            @completed = @patient_picked.plans.completed # @completed stores the patient's completed plans
          end

          if !@patient_picked.plans.not_yet_completed.empty? # The patient has incomplete ERP plans
            @not_yet_completed = @patient_picked.plans.not_yet_completed # @not_yet_completed stores the patient's incomplete plans
          end
        end
      else # Therapist did not choose a filter for filtering plans
        @plans = plans
      end # closes logic about filter selected
    elsif current_user.admin?
      if !params[:date].blank? # Admin filters plans by date created
        if params[:date] == "Today"
          if plans.from_today.empty? # If no plans were created today
            redirect_to plans_path, alert: "No ERP plans were created today."
          else
            @plans = plans.from_today
          end
        elsif params[:date] == "Past Plans"
          if plans.past_plans.empty? # If no plans were created prior to today
            redirect_to plans_path, alert: "No ERP plans were created prior to today."
          else
            @plans = plans.past_plans
          end
        end # closes logic for params[:date]
      elsif !params[:stepless].blank? # Admin filters plans by preliminary plans (plans without steps)
        if plans.stepless.empty? # all plans HAVE steps
          redirect_to plans_path, alert: "No preliminary plans were found; all ERP plans have at least one step."
        else
          @plans = plans.stepless # stores array of all plans without steps
        end
      elsif !params[:completion].blank? # Admin filters plans by whether or not plan is completed
        if plans.with_steps.empty? # If NO plans with at least 1 step were found (i.e. all plans have no steps)
          redirect_to plans_path, alert: "ERP plans must have at least 1 step before assessing status of completion."
        else # Plans with at least 1 step were found
          if params[:completion] == "Completed"
            if plans.completed.empty? # this means that plans with at least 1 step were found, but none of these plans were completed
              redirect_to plans_path, alert: "Completed ERP plans were not found."
            else
              @plans = plans.completed # stores array of completed plans (each containing at least 1 step)
            end
          elsif params[:completion] == "Not Yet Completed"
            if plans.not_yet_completed.empty? # plans with at least 1 step were found, but these plans were completed
              redirect_to plans_path, alert: "Unfinished ERP plans were not found."
            else
              @plans = plans.not_yet_completed # stores array of incomplete plans (each containing at least 1 step)
            end
          end # closes logic starting with if params[:completion] == "Completed"
        end # closes logic from if plans.with_steps.empty?
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
