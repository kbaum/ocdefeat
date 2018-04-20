class ObsessionsController < ApplicationController
  before_action :set_obsession, only: [:show, :edit, :update, :destroy]
  before_action :count_obsessions, only: [:index]

  def new
    @obsession = Obsession.new # @obsession instance for form_for to wrap around
    authorize @obsession
    @themes = Theme.all # @themes stores all OCD themes so user can select which existing theme their new obsession pertains to
  end

  def create
    @obsession = current_user.obsessions.build(obsession_params)
    authorize @obsession

    if @obsession.save
      redirect_to obsession_path(@obsession), notice: "Your obsession was successfully created!"
    else
      flash.now[:error] = "Your attempt to create an obsession was unsuccessful. Please try again."
      render :new
    end
  end

  def index # implicitly renders app/views/obsessions/index.html.erb
    obsessions = policy_scope(Obsession)

    if current_user.therapist?
      @patients = User.where(role: 1)

      if !params[:patient].blank? # if therapist chose to filter obsessions by patient -- params[:patient] is the primary key ID of the patient selected by name from dropdown
        if @patients.find(params[:patient]).obsessions.empty?
          redirect_to obsessions_path, alert: "That patient currently has no obsessions!"
        else
          @obsessions = obsessions.by_patient(params[:patient])
        end
      elsif !params[:date].blank? # if therapist chose to filter obsessions by date of creation
        if params[:date] == "Today"
          @obsessions = obsessions.from_today
        else
          @obsessions = obsessions.old_obsessions
        end
      elsif !params[:distressed].blank?
        obsession = Obsession.most_distressing_obsession_by_user(params[:distressed])

        if obsession.nil?
          redirect_to obsessions_path, alert: "That user currently has no obsessions!"
        else
          @obsession = obsession
        end
      else
        @obsessions = obsessions
      end
    elsif current_user.patient?
      if !params[:ocd_theme].blank?
        @obsessions = obsessions.by_theme(params[:ocd_theme])
      elsif !params[:anxiety_amount].blank?
        if params[:anxiety_amount] == "Least to Most Distressing"
          @obsessions = obsessions.least_to_most_distressing
        else
          @obsessions = obsessions.most_to_least_distressing
        end
      elsif !params[:time_taken].blank?
        if params[:time_taken] == "Least to Most Time-Consuming"
          @obsessions = obsessions.least_to_most_time_consuming
        else
          @obsessions = obsessions.most_to_least_time_consuming
        end
      end
    end
  end

  def show
    authorize @obsession
  end

  def edit
    authorize @obsession
    @themes = Theme.all
  end

  def update
    authorize @obsession

    if @obsession.update(obsession_params)
      redirect_to obsession_path(@obsession), notice: "Your obsession was successfully updated!"
    else
      flash.now[:error] = "Your attempt to edit your obsession was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy
    authorize @obsession
    @obsession.destroy
    redirect_to user_path(current_user), notice: "Congratulations on defeating your obsession!"
  end

  private

    def set_obsession
      @obsession = Obsession.find(params[:id])
    end

    def count_obsessions # this method is called before #index
      obsessions = policy_scope(Obsession)
      if current_user.therapist? && obsessions.empty?
        redirect_to user_path(current_user), alert: "None of your patients are currently obsessing, so there are no obsessions to filter!"
      elsif current_user.patient? && current_user.obsessions.empty?
        redirect_to user_path(current_user), alert: "Looks like you haven't been obsessing lately! No obsessions were found."
      end
    end

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
