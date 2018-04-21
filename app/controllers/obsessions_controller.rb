class ObsessionsController < ApplicationController
  before_action :set_obsession, only: [:show, :edit, :update, :destroy]
  before_action :count_obsessions, only: :index

  def index
    obsessions = policy_scope(Obsession)
    @patients = User.where(role: 1)
    @themes = Theme.all

    if current_user.admin?
      if !params[:num_plans].blank? # Admin filters obsessions by number of ERP plans
        if params[:num_plans] == "Least to Most ERP Plans"
          @obsessions = obsessions.least_to_most_desensitized
        else
          @obsessions = obsessions.most_to_least_desensitized
        end
      elsif !params[:date].blank? # Admin filters obsessions by date created
        if params[:date] == "Today"
          @obsessions = obsessions.from_today
        else
          @obsessions = obsessions.old_obsessions
        end
      else # Admin did not choose a filter, so all patients' obsessions are listed
        @obsessions = obsessions
      end
    elsif current_user.therapist?
      if !params[:patient].blank? # Therapist filters obsessions by patient -- params[:patient] is the ID of the patient selected by name from dropdown
        if @patients.find(params[:patient]).obsessions.empty? # if the selected patient has no obsessions
          redirect_to obsessions_path, alert: "That patient currently has no obsessions!"
        else
          @obsessions = obsessions.by_patient(params[:patient])
        end
      elsif !params[:distressed].blank? # Therapist filters obsessions by a patient's most distressing obsession -- params[:distressed] is the ID of the user selected to find that user's most distressing obsession
        obsession = Obsession.most_distressing_by_user(params[:distressed]) # obsession will either be nil or the user's obsession instance with the highest anxiety_rating attribute value

        if obsession.nil? # the selected user has no obsessions
          redirect_to obsessions_path, alert: "That patient currently has no obsessions, so no obsession is deemed most distressing!"
        else
          @obsession = obsession
        end
      elsif !params[:consumed].blank? # Therapist filters obsessions by a patient's most time-consuming obsession -- params[:consumed] is the ID of the user selected to find that user's most time-consuming obsession
        obsession = Obsession.most_time_consuming_by_user(params[:consumed])

        if obsession.nil? # the selected user has no obsessions
          redirect_to obsessions_path, alert: "That patient currently has no obsessions, so no obsession is deemed most time-consuming!"
        else
          @obsession = obsession
        end
      elsif !params[:ocd_subset].blank? # Therapist filters obsessions by OCD subset
        obsessions = obsessions.by_theme(params[:ocd_subset])
        if obsessions.empty?
          redirect_to obsessions_path, alert: "No obsessions pertain to this OCD theme."
        else
          @obsessions = obsessions
        end
      else # Therapist did not choose a filter, so all patients' obsessions are listed
        @obsessions = obsessions
      end
    elsif current_user.patient?
      if !params[:ocd_theme].blank? # Patient filtering her own obsessions by OCD theme
        obsessions = obsessions.by_theme(params[:ocd_theme])

        if obsessions.empty?
          redirect_to obsessions_path, alert: "No obsessions pertain to this OCD theme."
        else
          @obsessions = obsessions
        end
      elsif !params[:anxiety_amount].blank? # Patient filtering her own obsessions by anxiety_rating
        if params[:anxiety_amount] == "Least to Most Distressing"
          @obsessions = obsessions.least_to_most_distressing
        else
          @obsessions = obsessions.most_to_least_distressing
        end
      elsif !params[:time_taken].blank? # Patient filtering her own obsessions by time_consumed
        if params[:time_taken] == "Least to Most Time-Consuming"
          @obsessions = obsessions.least_to_most_time_consuming
        else
          @obsessions = obsessions.most_to_least_time_consuming
        end
      else # Patient did not choose a filter, so all of her own obsessions are listed
        @obsessions = obsessions
      end
    end
  end

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

    def count_obsessions # this method is called before #index action
      obsessions = policy_scope(Obsession)
      if current_user.admin? && obsessions.empty?
        redirect_to user_path(current_user), alert: "The obsessions log is currently empty!"
      elsif current_user.therapist? && obsessions.empty?
        redirect_to user_path(current_user), alert: "None of your patients are currently obsessing, and all past obsessions have been defeated and deleted!"
      elsif current_user.patient? && current_user.obsessions.empty?
        redirect_to user_path(current_user), alert: "You're making progress! Looks like you haven't been obsessing lately! No obsessions were found."
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
