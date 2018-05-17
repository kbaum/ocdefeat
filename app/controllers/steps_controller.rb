class StepsController < ApplicationController
  before_action :check_completion, only: [:edit, :update]
  before_action :set_step_and_parent_plan, only: [:show, :destroy]

  def create # POST request to "/plans/:plan_id/steps" maps to steps#create
    @step = Step.new(step_params) # new step will automatically belong to plan b/c plan_id is stored in params
    authorize @step
    if @step.save
      redirect_to plan_path(@step.plan), notice: "A new step has been added to this ERP plan!"
    else
      flash.now[:error] = "Your attempt to add a new step to this ERP plan was unsuccessful. Please try again."
      render "plans/show"
    end
  end

  def edit # GET request to "/plans/:plan_id/steps/:id/edit" maps to steps#edit
    authorize @step
  end

  def destroy # deleting a step - DELETE request to "/plans/:plan_id/steps/:id" mapped to steps#destroy
    authorize @step
    @step.destroy
    redirect_to plan_path(@step.plan), notice: "A step was successfully deleted from this ERP plan!"
  end

  private
    # Finding an associated step - only finding step that already belongs to that plan - 2 queries but protecting against URL hack
    def set_step_and_parent_plan # called before steps#edit, steps#update, steps#destroy
      @plan = Plan.find(params[:plan_id])
      @step = @plan.steps.find(params[:id])
    end

    def step_params
      params.require(:step).permit(
        :instructions,
        :duration,
        :plan_id,
        :discomfort_degree,
        :status
      )
    end

end
