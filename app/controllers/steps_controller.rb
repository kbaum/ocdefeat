class StepsController < ApplicationController
  before_action :check_completion, only: [:edit, :update]
  before_action :set_step_and_parent_plan, only: [:edit, :update, :destroy]

  def create # POST request to "/plans/:plan_id/steps" maps to steps#create
    @step = Step.new(step_params)
    authorize @step
    if @step.save
      redirect_to plan_path(@step.plan), notice: "A new step has been added to this ERP plan!"
    else
      @plan = @step.plan # to pass to rendered template app/views/plans/show.html.erb
      flash.now[:error] = "Your attempt to add a new step to this ERP plan was unsuccessful. Please try again."
      render "plans/show"
    end
  end

  def edit # GET request to "/steps/:id/edit" maps to steps#edit
    authorize @step
  end

  def update # PATCH request to "/plans/:plan_id/steps/:id" maps to steps#update
    authorize @step
    if @step.update(step_params)
      if @step.complete? # If the step is updated from incomplete to complete (status changes from 0 to 1)
        redirect_to plan_path(@step.plan), notice: "Milestone accomplished! You're one step closer to defeating OCD!"
      else
        redirect_to plan_path(@step.plan), notice: "You successfully modified a step in this ERP plan!"
      end
    else
      flash.now[:error] = "Your attempt to edit this ERP exercise was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy # deleting a step - DELETE request to "/plans/:plan_id/steps/:id" maps to steps#destroy
    authorize @step
    @step.destroy
    redirect_to plan_path(@plan), notice: "A step was successfully deleted from this ERP plan!"
  end

  private

    def check_completion
      @step = Step.find(params[:id])
      if @step.complete?
        redirect_to plan_path(@step.plan), alert: "You already performed this ERP exercise, so there is no need to modify this step!"
      end
    end

    def set_step_and_parent_plan
      @step = Step.find(params[:id])
      @plan = @step.plan
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
