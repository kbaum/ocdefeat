class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy]

  def index
    @plans = policy_scope(Plan)
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
    @plan_steps = @plan.steps unless @plan.steps.empty?
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

    def plan_params
      params.require(:plan).permit(
        :title,
        :goal,
        :obsession_id
      )
    end
end
