class PlansController < ApplicationController
  before_action :prepare_plan, only: [:show, :edit, :update, :destroy]
  before_action :prevent_plans_viewing, only: [:index]
  before_action :preserve_plan, only: [:edit, :update]
  include AdminFiltersConcern

  def index
    plans = policy_scope(Plan)
    @done = plans.accomplished if current_user.patient?
    @undone = plans.unaccomplished if current_user.patient?
    @counselees = policy_scope(User) if current_user.therapist?
    @themes = policy_scope(Theme) unless current_user.admin?
    @obsessions = policy_scope(Obsession) unless current_user.admin? # the patient's own obsessions / the therapist's patients' obsessions
    @plans = PlanFinder.new(plans).call(filter_plans_params).decorate unless current_user.admin?
    @plans = filter_by_date.decorate unless filter_by_date.nil? || !current_user.admin?
  end

  def new # Route helper #new_obsession_plan_path(obsession) returns GET "/obsessions/:obsession_id/plans/new" = where form is presented to create a new plan for an obsession
    @obsession = Obsession.find(params[:obsession_id]).decorate # @obsession = ObsessionDecorator object so I can call @obsession.hypotheticalize in app/views/plans/new.html.erb
    @plan = Plan.new # instance for form_with to wrap around
    authorize @plan # a patient (user w/ role 1) can create a plan overview
  end

  def create # When the form to create a new plan is submitted, form data is sent via POST request to "/obsessions/:obsession_id/plans"
    obsession = Obsession.find(params[:obsession_id])
    @plan = obsession.plans.build(plan_params)
    authorize @plan

    if @plan.save
      redirect_to plan_path(@plan), flash: { success: "You successfully created the ERP plan entitled \"#{@plan.title}.\"" }
    else
      @obsession = obsession.decorate # Need ObsessionDecorator object b/c I call #hypotheticalize when rerendering new plan form
      flash.now[:error] = "Your attempt to create a new ERP plan was unsuccessful. Please try again."
      render :new
    end
  end

  def show
    authorize @plan # A patient can view her own plans' show pages. A therapist can view her patients' plans' show pages.
    @plan = @plan.decorate # reassign @plan to PlanDecorator object right before rendering plan show view
    @step = Step.new # define instance for form_with to wrap around in nested resource form to create a new step on plan show page
  end

  def edit
    authorize @plan
  end

  def update # PATCH or PUT request to "/plans/:id" maps to plans#update due to shallow nesting
    authorize @plan
    if @plan.update_attributes(permitted_attributes(@plan))
      message =
        if @plan.finished? # If the plan is updated from unfinished to finished (boolean value)
          "Congratulations on developing anxiety tolerance by finishing this ERP plan!"
        else
          "An overview of this ERP plan was successfully updated!"
        end
      redirect_to plan_path(@plan), flash: { success: message }
    else # If user did NOT try to update plan w/ blank title/goal, since flooded is always T/F, the plan must be invalid b/c user tried to mark plan w/ no steps/at least one incomplete step as finished
      @plan = @plan.decorate if !@plan.title.blank? && !@plan.goal.blank? # Only call #decorate if the user tried to mark plan as finished and it's invalid
      flash.now[:error] = "Your attempt to edit this ERP plan was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy  # DELETE request to "/plans/:id" maps to plans#destroy
    authorize @plan
    @plan.destroy
    redirect_to plans_path, flash: { success: "You successfully deleted an ERP plan!" }
  end

  private
    def preserve_plan
      plan = Plan.find(params[:id])
      if plan.finished?
        redirect_to plan_path(plan), alert: "You already accomplished and archived this ERP plan!"
      end
    end

    def prepare_plan
      @plan = Plan.find(params[:id])
    end

    def prevent_plans_viewing # called before plans#index
      if current_user.unassigned?
        redirect_to about_path, alert: "An admin must assign your role before you can view the Index of ERP Plans, but you can learn about ERP here."
      elsif current_user.patient? && current_user.plans.empty? && !current_user.obsessions.empty? # The patient has no plans AND the patient has at least 1 obsession for which no plans were designed
        first_planless_obsession = current_user.obsessions.first
        redirect_to new_obsession_plan_path(first_planless_obsession), alert: "Looks like you're obsessing and need to gain some exposure. Why not design an ERP plan for this obsession now?"
      elsif current_user.therapist? && current_user.counselees.empty?
        redirect_to user_path(current_user), alert: "There are no ERP plans for you to review since you currently have no patients!"
      elsif policy_scope(Plan).empty? # If there are no plans to view (the therapist has patients, the patient doesn't have obsessions)
        msg =
          if current_user.admin?
            "The Index of ERP plans is currently empty."
          elsif current_user.therapist?
            "No ERP plans designed by your patients were found."
          elsif current_user.patient? # If the user has no plans but also has no obsessions
            "Looks like you're not implementing any ERP plans, but that's okay since you're not obsessing!"
          end
        redirect_to root_url, alert: "#{msg}"
      end
    end

    def plan_params
      params.require(:plan).permit(:title, :goal, :flooded, :obsession_id, :finished)
    end

    def filter_plans_params
      params.permit(
        :title_terms,
        :obsession_targeted,
        :accomplishment,
        :delineation,
        :approach,
        :ocd_theme,
        :designer
      )
    end
end
