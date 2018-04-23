class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy]
  before_action :set_obsessions, only: [:index]

  def index
    plans = policy_scope(Plan)
    @patients = User.where(role: 1)
    @themes = Theme.all

    if current_user.patient?
      if !params[:title].blank? # Patient filters her own plans by title -- params[:title] stores unique title of plan
        @plan = Plan.by_title(params[:title])
      elsif !params[:obsession_targeted].blank? # Patient filters her own plans by the obsession targeted -- params[:obsession_targeted] is the ID of obsession for which the patient searches plans
        if Obsession.find(params[:obsession_targeted]).plans.empty?
          redirect_to plans_path, alert: "No ERP plans were found for that obsession!"
        else
          @plans = plans.by_obsession(params[:obsession_targeted])
        end
      else
        @plans = plans
      end
    end
  end

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
