class ObsessionsController < ApplicationController
  before_action :set_obsession, only: [:show, :edit, :update, :destroy]
  before_action :set_themes, only: [:new, :edit]
  before_action :prohibit_obsession_viewing, only: [:index]
  include AdminFiltersConcern

  def index
    obsessions = policy_scope(Obsession)
    @themes = policy_scope(Theme)
    @obsessions = ObsessionFinder.new(obsessions).call(filter_obsessions_params).decorate unless current_user.admin?

    if current_user.therapist?
      @counselees = policy_scope(User)

      if !params[:patient].blank? # Therapist filters obsessions by patient -- params[:patient] is the ID of the user selected from dropdown
        if @counselees.find(params[:patient]).obsessions.empty? # If the selected patient has no obsessions
          flash.now[:alert] = "Patient #{@counselees.find(params[:patient]).name} is not obsessing!"
        else
          @patient_obsessions = obsessions.by_patient(params[:patient]).decorate # stores AR::Relation of all the selected patient's obsessions
          flash.now[:notice] = "Patient #{@patient_obsessions.first.patient_name} has #{plural_inflection(@patient_obsessions)}!"
        end
      elsif !params[:distressed].blank? # Therapist filters obsessions by a patient's obsessions ordered from highest to lowest anxiety_rating.
        patient_picked = @counselees.find(params[:distressed]) # params[:distressed] is the ID of the user whose obsessions we're ordering by descending distress degree.
        if patient_picked.obsessions.empty? # If the selected patient has no obsessions
          flash.now[:alert] = "#{patient_picked.name} is not distressed, as this patient is not obsessing about anything!"
        else # The selected patient has obsessions
          first_rating = patient_picked.obsessions.first.anxiety_rating
          if patient_picked.obsession_count == 1 # If the selected patient only has 1 obsession
            @patient_obsessions = patient_picked.obsessions.decorate
            flash.now[:notice] = "Patient #{patient_picked.name} only has one obsession rated at anxiety level #{first_rating}!"
          else # If the selected patient has more than 1 obsession
            if patient_picked.obsessions.all? {|o| o.anxiety_rating == first_rating} # If all of the selected patient's obsessions have the same anxiety_rating, none are displayed
              flash.now[:alert] = "#{patient_picked.name}'s obsessions cannot be ordered from most to least distressing, as this patient rated each obsession at anxiety level #{first_rating}."
            else # Patient has multiple obsessions that do NOT all have the same anxiety_rating
              @patient_obsessions = patient_picked.obsessions.most_to_least_distressing.decorate
              flash.now[:notice] = "#{patient_picked.name}'s obsessions are ordered from most to least distressing, so you can prioritize treating the obsessions that bring this patient the most discomfort!"
            end
          end
        end
      elsif !params[:consumed].blank? # Therapist filters obsessions by a patient's obsessions ordered from most to least time-consuming
        patient_picked = @counselees.find(params[:consumed]) # params[:consumed] is the ID of the user whose obsessions we're ordering from most to least time-consuming
        if patient_picked.obsessions.empty? # If the selected patient has no obsessions
          flash.now[:alert] = "#{patient_picked.name} has time to meditate with a worry-free mind, as this patient is not obsessing about anything!"
        else # The selected patient has obsessions
          first_timeframe = patient_picked.obsessions.first.time_consumed
          if patient_picked.obsession_count == 1 # If the selected patient only has 1 obsession
            @patient_obsessions = patient_picked.obsessions.decorate
            flash.now[:notice] = "#{patient_picked.name} only has one obsession that consumes #{first_timeframe} #{'hour'.pluralize(first_timeframe)} of the patient's time daily."
          else # If the selected patient has more than 1 obsession
            if patient_picked.obsessions.all? {|o| o.time_consumed == first_timeframe} # all of the selected patient's obsessions consume the same amount of time daily, so none are displayed
              flash.now[:alert] = "#{patient_picked.name}'s obsessions cannot be ordered from most to least time-consuming, as each obsession consumes #{first_timeframe} #{'hour'.pluralize(first_timeframe)} daily."
            else # The patient has multiple obsessions that do NOT all take up the same amount of time
              @patient_obsessions = patient_picked.obsessions.most_to_least_time_consuming.decorate
              flash.now[:notice] = "#{patient_picked.name}'s obsessions are ordered from most to least time-consuming, so you can prioritize treating the obsessions that take up the most time!"
            end
          end
        end
      elsif !params[:planless].blank? # Therapist filters obsessions by a patient's obsessions that lack ERP plans
        patient_picked = @counselees.find(params[:planless]) # params[:planless] is the ID of the user
        if patient_picked.obsessions.empty? # If the selected user has no obsessions
          flash.now[:alert] = "#{patient_picked.name} has no obsessions, so there is no need for this patient to practice Exposure and Response Prevention (ERP)."
        elsif patient_picked.obsessions.sans_plans.empty? # If the selected patient has obsessions, but all of these obsessions have ERP plans
          flash.now[:alert] = "Patient #{patient_picked.name} diligently designed ERP plans for every obsession."
        else # If the patient has obsessions for which no ERP plans were designed
          @patient_obsessions = patient_picked.obsessions.sans_plans.decorate
          flash.now[:notice] = "Patient #{patient_picked.name} has #{plural_inflection(@patient_obsessions)} for which no ERP plans were designed."
        end
      else # Therapist did not select a filter
        @patient_obsessions = obsessions.decorate # stores the therapist's patients' obsessions
      end
    elsif current_user.admin?
      @obsessions = filter_by_date.decorate unless filter_by_date.nil?
    end
  end

  def new
    @obsession = Obsession.new # instance for form_for to wrap around
    authorize @obsession
  end

  def create
    @obsession = current_user.obsessions.build(obsession_params)
    authorize @obsession

    if @obsession.save
      redirect_to obsession_path(@obsession), flash: { success: "You successfully recorded a new obsession!" }
    else
      flash.now[:error] = "Your attempt to record a new obsession was unsuccessful. Please try again."
      render :new
    end
  end

  def show
    authorize @obsession
    @obsession = @obsession.decorate # call #decorate on obsession instance right before rendering obsession show page
    @comment = Comment.new.decorate # instance for form_for to wrap around (creating a new comment on obsession show pg)
  end

  def edit
    authorize @obsession
  end

  def update
    authorize @obsession
    if @obsession.update_attributes(permitted_attributes(@obsession))
      @obsession = @obsession.decorate # only decorate instance AFTER it's updated in DB, right before presenting show view
      redirect_to obsession_path(@obsession), flash: { success: "Your obsession was successfully updated!" }
    else
      flash.now[:error] = "Your attempt to edit your obsession was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy
    authorize @obsession
    @obsession.destroy
    redirect_to obsessions_path, flash: { success: "Congratulations on defeating your obsession!" }
  end

  private

    def set_obsession
      @obsession = Obsession.find(params[:id])
    end

    def set_themes
      @themes = policy_scope(Theme) # Theme.all
    end

    def prohibit_obsession_viewing # this method is called before obsessions#index
      if current_user.unassigned?
        redirect_to themes_path, alert: "An admin must formally assign your role before you can view the Obsessions Log, but you can read about common OCD themes here."
      elsif current_user.therapist? && current_user.counselees.empty?
        redirect_to user_path(current_user), alert: "There are no obsessions for you to analyze since you currently have no patients!"
      elsif policy_scope(Obsession).empty? # If there are no obsessions to view (and therapist has patients)
        message =
          if current_user.patient?
            "Looks like you're managing your OCD well! No obsessions were found."
          elsif current_user.therapist?
            "Your patients are making progress! No one is currently obsessing."
          elsif current_user.admin?
            "The Obsessions Log is currently empty."
          end
        redirect_to root_path, alert: "#{message}"
      end
    end

    def obsession_params
      params.require(:obsession).permit(
        :user_id,
        :intrusive_thought,
        :triggers,
        :time_consumed,
        :anxiety_rating,
        :symptoms,
        :rituals,
        :theme_id,
        :search
      )
    end

    def filter_obsessions_params
      params.permit(
        :search_thoughts,
        :min_time_consumed,
        :max_time_consumed,
        :approach,
        :min_anxiety_rating,
        :max_anxiety_rating,
        :ocd_theme
      )
    end
  end
