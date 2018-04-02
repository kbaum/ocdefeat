class ObsessionsController < ApplicationController
  def new
    @obsession = Obsession.new # @obsession instance for form_for to wrap around
    @categories = Category.all # User can select which existing category their new obsession pertains to
  end

  def show
  end

  def edit
  end
end
