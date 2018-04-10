class StepsController < ApplicationController

  def create
    @step = Step.new(step_params)
    authorize @step
    if @step.save
      redirect_to plan_path(@step.plan), notice: "A new step has been added to this ERP plan!"
    else
      flash.now[:error] = "Your attempt to add a new step to this ERP plan was unsuccessful. Please try again."
      render "plans/show"
    end
  end

  def edit # GET request to "/plans/:plan_id/steps/:id/edit" maps to steps#edit
    @plan = Plan.find(params[:plan_id])
    @step = @plan.steps.find(params[:id])
  end

  def update # PATCH request to "/plans/:plan_id/steps/:id" maps to steps#update
    @plan = Plan.find(params[:plan_id])
    @step = @plan.steps.find(params[:id]) # Finding an associated step - only finding step that already belongs to that plan - 2 queries but protecting against URL hack
    authorize @step

    if @step.update(step_params)
      redirect_to plan_path(@plan), notice: "You successfully modified an ERP exercise!"
    else
      flash.now[:error] = "Your attempt to edit this ERP exercise was unsuccessful. Please try again."
      render :edit
    end
  end

  private

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
