class ObsessionsController < ApplicationController
  before_action :set_obsession, only: [:show, :edit, :update, :destroy]
  before_action :set_themes, only: [:new, :edit]
  before_action :require_obsessions, only: [:index]

  def index
    obsessions = policy_scope(Obsession)
    @themes = policy_scope(Theme)

    if current_user.patient? # patient is guaranteed to have at least 1 obsession due to #require_obsessions
      @obsessions = PatientObsessionFinder.new(obsessions).call(patient_filters_obsessions_params)
    elsif current_user.therapist?
      @obsessions = PatientObsessionFinder.new(obsessions).call(patient_filters_obsessions_params)
      @counselees = policy_scope(User)
      #elsif !params[:patient].blank? # Therapist filters obsessions by patient -- params[:patient] is the ID of the user selected from dropdown
        #if @counselees.find(params[:patient]).obsessions.empty? # If the selected patient has no obsessions
          #flash.now[:alert] = "Patient #{@counselees.find(params[:patient]).name} is not obsessing!"
        #else
          #@obsessions = obsessions.by_patient(params[:patient]) # stores AR::Relation of all the selected patient's obsessions
          #flash.now[:notice] = "Patient #{@obsessions.first.patient_name} has #{plural_inflection(@obsessions)}!"
        #end
      #elsif !params[:distressed].blank? # Therapist filters obsessions by a patient's obsessions ordered from highest to lowest anxiety_rating.
        #patient_picked = @counselees.find(params[:distressed]) # params[:distressed] is the ID of the user whose obsessions we're ordering by descending distress degree.
        #if patient_picked.obsessions.empty? # If the selected patient has no obsessions
          #flash.now[:alert] = "#{patient_picked.name} is not distressed, as this patient is not obsessing about anything!"
        #else # The selected patient has obsessions
          #first_rating = patient_picked.obsessions.first.anxiety_rating
          #if patient_picked.obsession_count == 1 # If the selected patient only has 1 obsession
            #@obsessions = patient_picked.obsessions # stores AR::Relation containing 1 obsession
            #flash.now[:notice] = "Patient #{patient_picked.name} only has one obsession rated at anxiety level #{first_rating}!"
          #else # If the selected patient has more than 1 obsession
            #if patient_picked.obsessions.all? {|o| o.anxiety_rating == first_rating} # If all of the selected patient's obsessions have the same anxiety_rating, none are displayed
              #flash.now[:alert] = "#{patient_picked.name}'s obsessions cannot be ordered from most to least distressing, as this patient rated each obsession at anxiety level #{first_rating}."
            #else # Patient has multiple obsessions that do NOT all have the same anxiety_rating
              #@obsessions = patient_picked.obsessions.most_to_least_distressing # stores AR::Relation of the selected patient's obsessions ordered from most to least distressing
              #flash.now[:notice] = "#{patient_picked.name}'s obsessions are ordered from most to least distressing, so you can prioritize treating the obsessions that bring this patient the most discomfort!"
            #end
          #end
        #end
      #elsif !params[:consumed].blank? # Therapist filters obsessions by a patient's obsessions ordered from most to least time-consuming
        #patient_picked = @counselees.find(params[:consumed]) # params[:consumed] is the ID of the user whose obsessions we're ordering from most to least time-consuming
        #if patient_picked.obsessions.empty? # If the selected patient has no obsessions
          #flash.now[:alert] = "#{patient_picked.name} has time to meditate with a worry-free mind, as this patient is not obsessing about anything!"
        #else # The selected patient has obsessions
          #first_timeframe = patient_picked.obsessions.first.time_consumed
          #if patient_picked.obsession_count == 1 # If the selected patient only has 1 obsession
            #@obsessions = patient_picked.obsessions # stores AR::Relation containing 1 obsession
            #flash.now[:notice] = "#{patient_picked.name} only has one obsession that consumes #{first_timeframe} #{'hour'.pluralize(first_timeframe)} of the patient's time daily."
          #else # If the selected patient has more than 1 obsession
            #if patient_picked.obsessions.all? {|o| o.time_consumed == first_timeframe} # all of the selected patient's obsessions consume the same amount of time daily, so none are displayed
              #flash.now[:alert] = "#{patient_picked.name}'s obsessions cannot be ordered from most to least time-consuming, as each obsession consumes #{first_timeframe} #{'hour'.pluralize(first_timeframe)} daily."
            #else # The patient has multiple obsessions that do NOT all take up the same amount of time
              #@obsessions = patient_picked.obsessions.most_to_least_time_consuming # stores AR::Relation of the selected patient's obsessions ordered from most to least time-consuming
              #flash.now[:notice] = "#{patient_picked.name}'s obsessions are ordered from most to least time-consuming, so you can prioritize treating the obsessions that take up the most time!"
            #end
          #end
        #end
      #elsif !params[:planless].blank? # Therapist filters obsessions by a patient's obsessions that lack ERP plans
        #patient_picked = @counselees.find(params[:planless]) # params[:planless] is the ID of the user
        #if patient_picked.obsessions.empty? # If the selected user has no obsessions
          #flash.now[:alert] = "#{patient_picked.name} has no obsessions, so there is no need for this patient to practice Exposure and Response Prevention (ERP)."
        #elsif patient_picked.obsessions.sans_plans.empty? # If the selected patient has obsessions, but all of these obsessions have ERP plans
          #flash.now[:alert] = "Patient #{patient_picked.name} diligently designed ERP plans for every obsession."
        #else # If the patient has obsessions for which no ERP plans were designed
          #@obsessions = patient_picked.obsessions.sans_plans
          #flash.now[:notice] = "Patient #{patient_picked.name} has #{plural_inflection(@obsessions)} for which no ERP plans were designed."
        #end
      #else # Therapist did not select a filter
        #@obsessions = obsessions # stores the therapist's patients' obsessions
      #end
    elsif current_user.admin?
      if !params[:date].blank? # Admin filters obsessions by date created
        if params[:date] == "Today"
          if obsessions.from_today.empty? # If no obsessions were created today
            flash.now[:alert] = "No new obsessions were reported today."
          else
            @obsessions = obsessions.from_today # stores AR::Relation of all obsessions created today
            flash.now[:notice] = "You found #{plural_inflection(@obsessions)} reported today!"
          end
        elsif params[:date] == "Old Obsessions"
          if obsessions.before_today.empty? # If no obsessions were created prior to today
            flash.now[:alert] = "No obsessions were reported before today."
          else
            @obsessions = obsessions.before_today # stores AR::Relation of all obsessions created prior to today
            flash.now[:notice] = "You found #{plural_inflection(@obsessions)} reported before today!"
          end
        end
      else # Admin did not choose a filter
        @obsessions = obsessions # stores AR::Relation of all patients' obsessions
        flash.now[:notice] = "OCD spikes are sparsely detailed and displayed anonymously to preserve patient confidentiality."
      end
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
      redirect_to obsession_path(@obsession), flash: { success: "You successfully reported a new obsession!" }
    else
      flash.now[:error] = "Your attempt to report a new obsession was unsuccessful. Please try again."
      render :new
    end
  end

  def show
    authorize @obsession
    @comment = Comment.new # instance for form_for to wrap around (creating a new comment on obsession show pg)
  end

  def edit
    authorize @obsession
  end

  def update
    authorize @obsession

    if @obsession.update_attributes(permitted_attributes(@obsession))
      redirect_to obsession_path(@obsession), flash: { success: "Your obsession was successfully updated!" }
    else
      flash.now[:error] = "Your attempt to edit your obsession was unsuccessful. Please try again."
      render :edit
    end
  end

  def destroy
    authorize @obsession
    @obsession.destroy
    redirect_to user_path(current_user), flash: { success: "Congratulations on defeating your obsession!" }
  end

  private

    def set_obsession
      @obsession = Obsession.find(params[:id])
    end

    def set_themes
      @themes = policy_scope(Theme) # Theme.all
    end

    def require_obsessions # this method is called before obsessions#index
      if current_user.therapist? && current_user.counselees.empty?
        redirect_to user_path(current_user), alert: "There are no obsessions for you to analyze since you currently have no patients!"
      elsif policy_scope(Obsession).empty? # If there are no obsessions to view (and therapist has patients)
        msg = if current_user.patient?
          "Looks like you haven't been obsessing! No obsessions were found."
        elsif current_user.therapist?
          "Your patients are making progress! No one is currently obsessing, and all old obsessions were defeated and deleted!"
        elsif current_user.admin?
          "The Obsessions Log is currently empty."
        end
        redirect_to root_path, alert: "#{msg}"
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

    def patient_filters_obsessions_params
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
