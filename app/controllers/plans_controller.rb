class PlansController < ApplicationController
  def new
    @plan = Plan.new # instance for form_for to wrap around
  end

  def show
  end

  def edit
  end

  def index
  end
end
