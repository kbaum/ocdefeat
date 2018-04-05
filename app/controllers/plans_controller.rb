class PlansController < ApplicationController
  def new
    @plan = Plan.new # instance for form_for to wrap around
  end

  def create
    raise params.inspect
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
