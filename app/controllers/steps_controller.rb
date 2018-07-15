class StepsController < ApplicationController
  before_action :prevent_changes_if_plan_performed, only: [:create, :edit, :update, :destroy]
  before_action :check_completion, only: [:edit, :update, :destroy]
  before_action :set_step_and_parent_plan, only: [:edit, :update, :destroy]

  def create # POST request to "/plans/:plan_id/steps" maps to steps#create
    @step = Step.new(step_params) # Step automatically belongs to plan due to nested resource form in _step partial
    authorize @step
    if @step.save
      redirect_to plan_path(@step.plan), flash: { success: "A new step has been added to this ERP plan!" }
    else
      @plan = @step.plan.decorate # to pass to rendered template app/views/plans/show.html.erb
      flash.now[:error] = "Your attempt to add a new step to this ERP plan was unsuccessful. Please try again."
      render "plans/show"
    end
  end

  def edit # GET request to "/steps/:id/edit" maps to steps#edit
    authorize @step
  end

  def update # PATCH or PUT request to "/steps/:id" maps to steps#update due to shallow nesting
    authorize @step
    if @step.update(step_params) # A step that is already marked as complete cannot be updated due to #check_completion
      message =
        if @step.completed? # If the step is updated from incomplete to complete (boolean value)
          "Milestone accomplished! You're one step closer to defeating OCD!"
        else
          "You successfully modified a step in this ERP plan!"
        end
      redirect_to plan_path(@plan), flash: { success: message }
    else
      flash.now[:error] = "Your attempt to edit this ERP exercise was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy # deleting a step -  DELETE request to "/steps/:id" maps to steps#destroy
    authorize @step
    @step.destroy
    redirect_to plan_path(@plan), flash: { success: "A step was successfully deleted from this ERP plan!" }
  end

  private # Creating a new step on the plan show page - POST request to "/plans/:plan_id/steps" maps to steps#create
    def prevent_changes_if_plan_performed # Editing/updating/destroying a step - Step.find(params[:id])
      step = action_name == "create" ? Plan.find(params[:plan_id]).steps.build : Step.find(params[:id])
      redirect_to plan_path(step.plan), alert: "The steps that comprise an ERP plan cannot be changed once that plan is finished." if step.plan.finished?
    end

    def check_completion # Check if the step was already marked as complete before calling #edit, #update or #destroy (when plan is still unfinished)
      step = Step.find(params[:id])
      if step.completed?
        redirect_to plan_path(step.plan), alert: "A step that has already been performed cannot be modified!"
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
        :completed
      )
    end

end
# If steps#update is triggered, I know that the step is incomplete because a completed step cannot be updated due to #check_completion
# and I know that the plan to which the step belongs is not finished due to #prevent_changes_if_plan_performed
