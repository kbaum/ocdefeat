class ObsessionsController < ApplicationController
  def new
    @obsession = Obsession.new # @obsession instance for form_for to wrap around
    @themes = Theme.all # @themes stores all OCD themes so user can select which existing theme their new obsession pertains to
  end

  def create
    @obsession = current_user.obsessions.build(obsession_params)

    if @obsession.save
      redirect_to obsession_path(@obsession), notice: "Your obsession was successfully created!"
    else
      flash.now[:error] = "Your attempt to create an obsession was unsuccessful. Please try again."
      render :new
    end
  end

  def show
  end

  def edit
  end

  private

  def obsession_params
    params.require(:obsession).permit(
      :intrusive_thought,
      :triggers,
      :time_consumed,
      :anxiety_rating,
      :symptoms,
      :rituals,
      :theme_ids => [],
      :themes_attributes => [:name]
    )
  end
end
