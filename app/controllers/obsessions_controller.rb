class ObsessionsController < ApplicationController
  before_action :set_obsession, only: [:show, :edit, :update, :destroy]
  before_action :count_obsessions, only: :index

  def index
    obsessions = policy_scope(Obsession)
    @patients = User.where(role: 1)
    @themes = Theme.all

    if current_user.patient?
      if !params[:anxiety_amount].blank? # Patient filters her own obsessions by anxiety_rating -- params[:anxiety_amount] is the integer anxiety_rating attribute value
        if obsessions.by_anxiety_amount(params[:anxiety_amount]).empty? # If none of the patient's obsessions has the selected anxiety_rating
          @obsessions = nil
          flash.now[:alert] = "You did not rate any of your obsessions at anxiety level #{params[:anxiety_amount]}."
        else
          @obsessions = obsessions.by_anxiety_amount(params[:anxiety_amount]) # stores 'array' of the patient's obsessions with the selected anxiety_rating
          flash.now[:notice] = "You rated at least one obsession at anxiety level #{params[:anxiety_amount]}!"
        end
      elsif !params[:ocd_theme].blank? # Patient filters her own obsessions by OCD theme - params[:ocd_theme] is the ID of the theme in which the obsessions we're searching for are categorized
        theme_name = Theme.find(params[:ocd_theme]).name
        themed_obsessions = obsessions.by_theme(params[:ocd_theme])

        if themed_obsessions.empty? # If none of the patient's obsessions pertain to that theme
          @obsessions = nil
          flash.now[:alert] = "None of your obsessions pertain to \"#{theme_name}.\""
        else
          @obsessions = themed_obsessions # stores 'array' of the patient's obsessions categorized in the selected OCD theme
          flash.now[:notice] = "At least one of your obsessions is categorized as \"#{theme_name}!\""
        end
      elsif !params[:anxiety_ranking].blank? # Patient filters her own obsessions by anxiety_rating
        if current_user.obsessions.count == 1 # If the patient only has 1 obsession
          @obsession = current_user.obsessions.first # @obsession stores this single obsession
          flash.now[:alert] = "You only have one obsession with an anxiety rating of #{@obsession.anxiety_rating}!"
        else # the patient has more than 1 obsession
          distress_degree = current_user.obsessions.first.anxiety_rating
          if current_user.obsessions.all? {|o| o.anxiety_rating == distress_degree}
            @obsessions = obsessions # all of the patient's own obsessions, which have the same anxiety rating, are listed
            flash.now[:alert] = "Your obsessions cannot be ranked in order of ascending/descending anxiety rating, as each of your obsessions below has an anxiety rating of #{distress_degree}!"
          elsif params[:anxiety_ranking] == "Least to Most Distressing"
            @obsessions = obsessions.least_to_most_distressing
            flash.now[:notice] = "Your obsessions are listed in order of ascending anxiety rating!"
          else
            @obsessions = obsessions.most_to_least_distressing
            flash.now[:notice] = "Your obsessions are listed in order of descending anxiety rating!"
          end
        end
      elsif !params[:time_taken].blank? # Patient filters her own obsessions by time_consumed (hrs/day)
        if current_user.obsessions.count == 1 # If the patient only has 1 obsession
          @obsession = current_user.obsessions.first # @obsession stores this single obsession
          flash.now[:alert] = "You only have one obsession, which consumes #{@obsession.time_consumed} hour(s) of your time on a daily basis!"
        else # the patient has more than 1 obsession
          total_time = current_user.obsessions.first.time_consumed
          if current_user.obsessions.all? {|o| o.time_consumed == total_time}
            @obsessions = obsessions # all of the patient's own obsessions, which have the same time_consumed value of total_time, are listed
            flash.now[:alert] = "Your obsessions cannot be ranked in order of increasing/decreasing total time consumed, as each of your obsessions below takes #{total_time} hour(s) of your time daily!"
          elsif params[:time_taken] == "Least to Most Time-Consuming"
            @obsessions = obsessions.least_to_most_time_consuming
            flash.now[:notice] = "Your obsessions are listed in order of least to most time-consuming, measured in hours per day!"
          else
            @obsessions = obsessions.most_to_least_time_consuming
            flash.now[:notice] = "Your obsessions are listed in order of most to least time-consuming, measured in hours per day!"
          end
        end
      else # Patient did not choose a filter, so all of her own obsessions are listed
        @obsessions = obsessions # stores all of the patient's own obsessions
      end
    elsif current_user.therapist?
      if !params[:patient].blank? # Therapist filters obsessions by patient -- params[:patient] is the ID of the patient selected by name from dropdown
        patient_name = @patients.find(params[:patient]).name
        if @patients.find(params[:patient]).obsessions.empty? # if the selected patient has no obsessions
          @obsessions = nil
          flash.now[:alert] = "Patient #{patient_name} currently has no obsessions!"
        else
          @obsessions = obsessions.by_patient(params[:patient]) # stores 'array' of all the selected patient's obsessions
          flash.now[:notice] = "You found patient #{patient_name}'s obsessions!"
        end
      elsif !params[:distressed].blank? # Therapist filters obsessions by patient's obsessions ordered by descending distress degree
        patient_picked = @patients.find(params[:distressed])
        if patient_picked.obsessions.empty? # If the selected patient has no obsessions
          @obsessions = nil
          flash.now[:alert] = "Patient #{patient_picked.name} currently has no obsessions."
        else # The patient selected has obsessions
          first_rating = patient_picked.obsessions.first.anxiety_rating
          if patient_picked.obsession_count == 1 # If the selected patient only has one obsession
            flash.now[:alert] = "Patient #{patient_picked.name} only has one obsession rated at anxiety level #{first_rating}!"
          else # If the patient selected has more than 1 obsession
            if patient_picked.obsessions.all? {|o| o.anxiety_rating == first_rating}
              @obsessions = nil # all of the selected patient's obsessions have the same anxiety_rating, so none are displayed
              flash.now[:alert] = "#{patient_picked.name}'s obsessions cannot be ordered by descending distress degree, as this patient rated each obsession at anxiety level #{first_rating}."
            else # patient has multiple obsessions that do not all have the same anxiety_rating
              @obsessions = patient_picked.obsessions.most_to_least_distressing # stores 'array' of all the selected patient's obsessions ordered by descending distress degree
              flash.now[:notice] = "Patient #{patient_picked.name}'s obsessions are ordered by descending distress degree!"
            end
          end
        end
      else # Therapist did not select a filter
        @obsessions = obsessions # stores all patients' obsessions
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
    @obsession.obsessify(@obsession.intrusive_thought)
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
