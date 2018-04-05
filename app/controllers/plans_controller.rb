class PlansController < ApplicationController
  def new
    @plan = Plan.new # instance for form_for to wrap around
  end

  def create
    @plan = Plan.new(plan_params)
    
    if @plan.save
      redirect_to plan_path(@plan), notice: "You successfully created the ERP plan entitled #{@plan.title}!"
    else
      flash.now[:error] = "Your attempt to create a new ERP plan was unsuccessful. Please try again."
      render :new
    end
  end

  def show
  end

  def edit
  end

  def index
  end

  private

    def plan_params
      params.require(:plan).permit(
        :title,
        :goal,
        :obsession_id
      )
    end
end
