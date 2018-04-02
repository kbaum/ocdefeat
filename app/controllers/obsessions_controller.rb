class ObsessionsController < ApplicationController
  def new
    @obsession = Obsession.new # @obsession instance for form_for to wrap around
  end

  def show
  end

  def edit
  end
end
