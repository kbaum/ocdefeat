class ObsessionsController < ApplicationController
  before_action :set_obsession, only: [:show, :edit, :update, :destroy]
  before_action :require_obsessions, only: :index

  def index
    obsessions = policy_scope(Obsession) # patient only sees her own obsessions; admins and therapists see all
    @patients = User.patients
    @themes = policy_scope(Theme) # patients, therapists and admins see all themes

    if current_user.patient? # patient is guaranteed to have at least 1 obsession due to #require_obsessions
      if !params[:anxiety_amount].blank? # Patient filters her own obsessions by anxiety_rating -- params[:anxiety_amount] = anxiety_rating attribute value (an integer from 1-10)
        if obsessions.by_anxiety_amount(params[:anxiety_amount]).empty? # If none of the patient's obsessions has the selected anxiety_rating
          flash.now[:alert] = "None of your obsessions were rated at anxiety level #{params[:anxiety_amount]}."
        else
          @obsessions = obsessions.by_anxiety_amount(params[:anxiety_amount]) # stores AR::Relation of the patient's obsessions with the selected anxiety_rating
          flash.now[:notice] = "You rated #{plural_inflection(@obsessions)} at anxiety level #{params[:anxiety_amount]}!"
        end
      elsif !params[:anxiety_ranking].blank? # Patient filters her own obsessions by increasing/decreasing anxiety_rating
        if current_user.obsession_count == 1 # If the patient only has 1 obsession
          @obsessions = current_user.obsessions # @obsessions is AR::Relation storing 1 obsession
          flash.now[:notice] = "You only have one obsession with an anxiety rating of #{@obsessions.first.anxiety_rating}!"
        else # If the patient has more than 1 obsession
          distress_degree = current_user.obsessions.first.anxiety_rating # stores the patient's first obsession's anxiety_rating
          if current_user.obsessions.all? {|o| o.anxiety_rating == distress_degree} # all of the patient's obsessions have the same anxiety_rating, so none are displayed
            flash.now[:alert] = "Your obsessions cannot be ranked in order of anxiety rating, as you rated each obsession at anxiety level #{distress_degree}!"
          elsif params[:anxiety_ranking] == "Least to Most Distressing"
            @obsessions = obsessions.least_to_most_distressing
            flash.now[:notice] = "Your obsessions are ordered from least to most distressing!"
          else
            @obsessions = obsessions.most_to_least_distressing
            flash.now[:notice] = "Your obsessions are ordered from most to least distressing!"
          end
        end
      elsif !params[:time_taken].blank? # Patient filters her own obsessions by time_consumed (hrs/day)
        if current_user.obsession_count == 1 # If the patient only has 1 obsession
          @obsessions = current_user.obsessions # @obsessions is AR::Relation storing 1 obsession
          flash.now[:notice] = "You only have one obsession, which consumes #{@obsessions.first.time_consumed} #{'hour'.pluralize(@obsessions.first.time_consumed)} of your time on a daily basis!"
        else # If the patient has more than 1 obsession
          first_timeframe = current_user.obsessions.first.time_consumed
          if current_user.obsessions.all? {|o| o.time_consumed == first_timeframe} # The patient's own obsessions all have the same time_consumed value, so they're not displayed
            flash.now[:alert] = "Your obsessions cannot be ranked by amount of time spent obsessing, as each of your obsessions takes up #{first_timeframe} #{'hour'.pluralize(first_timeframe)} of your time daily!"
          elsif params[:time_taken] == "Least to Most Time-Consuming"
            @obsessions = obsessions.least_to_most_time_consuming
            flash.now[:notice] = "Your obsessions are ordered from least to most time-consuming!"
          else
            @obsessions = obsessions.most_to_least_time_consuming
            flash.now[:notice] = "Your obsessions are ordered from most to least time-consuming!"
          end
        end
      elsif !params[:ocd_theme].blank? # Patient filters her own obsessions by OCD theme - params[:ocd_theme] is the ID of the theme in which the obsessions we're searching for are classified
        if obsessions.by_theme(params[:ocd_theme]).empty? # If none of the patient's obsessions pertain to that theme
          flash.now[:alert] = "None of your obsessions pertain to \"#{Theme.find(params[:ocd_theme]).name}.\""
        else # 1 or more of the patient's obsessions are classified in the selected theme
          @obsessions = obsessions.by_theme(params[:ocd_theme]) # stores AR::Relation of the patient's obsessions that are classified in the selected OCD theme
          flash.now[:notice] = "The content of your obsessions revolves around \"#{Theme.find(params[:ocd_theme]).name}.\"
          Accordingly, #{sv_agreement(@obsessions)} classified in this OCD theme."
        end
      else # Patient did not choose a filter, so all of her own obsessions are listed
        @obsessions = obsessions # stores AR::Relation of all the patient's own obsessions
        flash.now[:notice] = "Your history of obsessions is recorded below."
      end
    elsif current_user.therapist?
      if !params[:patient].blank? # Therapist filters obsessions by patient -- params[:patient] is the ID of the user selected from dropdown
        if @patients.find(params[:patient]).obsessions.empty? # If the selected patient has no obsessions
          flash.now[:alert] = "Patient #{@patients.find(params[:patient]).name} is not obsessing!"
        else
          @obsessions = obsessions.by_patient(params[:patient]) # stores AR::Relation of all the selected patient's obsessions
          flash.now[:notice] = "Patient #{@patients.find(params[:patient]).name} has #{plural_inflection(@obsessions)}!"
        end
      elsif !params[:distressed].blank? # Therapist filters obsessions by a patient's obsessions ordered from highest to lowest anxiety_rating.
        patient_picked = @patients.find(params[:distressed]) # params[:distressed] is the ID of the user whose obsessions we're ordering by descending distress degree.
        if patient_picked.obsessions.empty? # If the selected patient has no obsessions
          flash.now[:alert] = "#{patient_picked.name} is not distressed, as this patient is not obsessing about anything!"
        else # The selected patient has obsessions
          first_rating = patient_picked.obsessions.first.anxiety_rating
          if patient_picked.obsession_count == 1 # If the selected patient only has 1 obsession
            @obsessions = patient_picked.obsessions # stores AR::Relation containing 1 obsession
            flash.now[:notice] = "Patient #{patient_picked.name} only has one obsession rated at anxiety level #{first_rating}!"
          else # If the selected patient has more than 1 obsession
            if patient_picked.obsessions.all? {|o| o.anxiety_rating == first_rating} # If all of the selected patient's obsessions have the same anxiety_rating, none are displayed
              flash.now[:alert] = "#{patient_picked.name}'s obsessions cannot be ordered from most to least distressing, as this patient rated each obsession at anxiety level #{first_rating}."
            else # Patient has multiple obsessions that do NOT all have the same anxiety_rating
              @obsessions = patient_picked.obsessions.most_to_least_distressing # stores AR::Relation of the selected patient's obsessions ordered from most to least distressing
              flash.now[:notice] = "#{patient_picked.name}'s obsessions are ordered from most to least distressing, so you can prioritize treating the obsessions that bring this patient the most discomfort!"
            end
          end
        end
      elsif !params[:consumed].blank? # Therapist filters obsessions by a patient's obsessions ordered from most to least time-consuming
        patient_picked = @patients.find(params[:consumed]) # params[:consumed] is the ID of the user whose obsessions we're ordering from most to least time-consuming
        if patient_picked.obsessions.empty? # If the selected patient has no obsessions
          flash.now[:alert] = "#{patient_picked.name} has time to meditate with a worry-free mind, as this patient is not obsessing about anything!"
        else # The selected patient has obsessions
          first_timeframe = patient_picked.obsessions.first.time_consumed
          if patient_picked.obsession_count == 1 # If the selected patient only has 1 obsession
            @obsessions = patient_picked.obsessions # stores AR::Relation containing 1 obsession
            flash.now[:notice] = "#{patient_picked.name} only has one obsession that consumes #{first_timeframe} #{'hour'.pluralize(first_timeframe)} of the patient's time daily."
          else # If the selected patient has more than 1 obsession
            if patient_picked.obsessions.all? {|o| o.time_consumed == first_timeframe} # all of the selected patient's obsessions consume the same amount of time daily, so none are displayed
              flash.now[:alert] = "#{patient_picked.name}'s obsessions cannot be ordered from most to least time-consuming, as each obsession consumes #{first_timeframe} #{'hour'.pluralize(first_timeframe)} daily."
            else # The patient has multiple obsessions that do NOT all take up the same amount of time
              @obsessions = patient_picked.obsessions.most_to_least_time_consuming # stores AR::Relation of the selected patient's obsessions ordered from most to least time-consuming
              flash.now[:notice] = "#{patient_picked.name}'s obsessions are ordered from most to least time-consuming, so you can prioritize treating the obsessions that waste the most time!"
            end
          end
        end
      elsif !params[:planless].blank? # Therapist filters obsessions by a patient's obsessions that lack ERP plans
        patient_picked = @patients.find(params[:planless]) # params[:planless] is the ID of the user
        if patient_picked.obsessions.empty? # If the selected user has no obsessions
          flash.now[:alert] = "#{patient_picked.name} has no obsessions, so there is no need for this patient to practice Exposure and Response Prevention (ERP)."
        elsif patient_picked.obsessions.sans_plans.empty? # If the selected patient has obsessions, but all of these obsessions have ERP plans
          flash.now[:alert] = "Patient #{patient_picked.name} diligently designed ERP plans for every obsession."
        else # If the patient has obsessions for which no ERP plans were designed
          @obsessions = patient_picked.obsessions.sans_plans
          flash.now[:notice] = "Patient #{patient_picked.name} has #{plural_inflection(@obsessions)} for which no ERP plans were designed!"
        end
      elsif !params[:ocd_subset].blank? # Therapist filters obsessions by OCD subset -- params[:ocd_subset] is the ID of the theme
        if obsessions.by_theme(params[:ocd_subset]).empty? # If no obsession is classified in the selected subset
          flash.now[:alert] = "No obsessions pertain to OCD subset \"#{Theme.find(params[:ocd_subset]).name}.\""
        else # At least one obsession is classified in the selected subset
          @obsessions = obsessions.by_theme(params[:ocd_subset])
          flash.now[:notice] = "#{sv_agreement(@obsessions)} classified as \"#{Theme.find(params[:ocd_subset]).name}!\""
        end
      else # Therapist did not select a filter
        @obsessions = obsessions # stores all patients' obsessions
        flash.now[:notice] = "A full psychiatric history of all patients' obsessions is recorded below!"
      end
    elsif current_user.admin?
      if !params[:plan_production].blank? # Admin filters obsessions by number of ERP plans per obsession
        if obsessions == obsessions.sans_plans # If all obsessions have 0 plans
          flash.now[:alert] = "No ERP plans were designed for any single obsession!"
        elsif obsessions.count == 1 # Only 1 obsession exists, but this obsession has some number of plan(s)
          @obsessions = obsessions # stores AR::Relation containing 1 obsession
          flash.now[:notice] = "The Obsessions Log only contains one obsession, which is targeted by #{@obsessions.first.plans_per_obsession} ERP #{'plan'.pluralize(@obsessions.first.plans_per_obsession)}."
        else # > 1 obsession, some of which have ERP plans, exist
          first_plan_count = obsessions.first.plans_per_obsession
          if obsessions.all? {|o| o.plans_per_obsession == first_plan_count}
            flash.now[:alert] = "Patients' obsessions cannot be sorted by number of ERP plans per obsession, as all obsessions are targeted by #{first_plan_count} ERP #{'plan'.pluralize(first_plan_count)}."
          else # There are multiple obsessions, and NOT all obsessions have the same number of ERP plans
            if params[:plan_production] == "Least to Most ERP Plans"
              @obsessions = obsessions.least_to_most_plans
              flash.now[:notice] = "Patients' obsessions are ordered from least to most ERP plans per obsession!"
            else
              @obsessions = obsessions.most_to_least_plans
              flash.now[:notice] = "Patients' obsessions are ordered from most to least ERP plans per obsession!"
            end
          end
        end
      elsif !params[:date].blank? # Admin filters obsessions by date created
        if params[:date] == "Today"
          if obsessions.from_today.empty? # If no obsessions were created today
            flash.now[:alert] = "No new obsessions were reported today."
          else
            @obsessions = obsessions.from_today # stores AR::Relation of all obsessions created today
            flash.now[:notice] = "You found #{plural_inflection(@obsessions)} reported today!"
          end
        elsif params[:date] == "Old Obsessions"
          if obsessions.old_obsessions.empty? # If no obsessions were created prior to today
            flash.now[:alert] = "No obsessions were reported before today."
          else
            @obsessions = obsessions.old_obsessions # stores AR::Relation of all obsessions created prior to today
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
    @obsession = Obsession.new # @obsession instance for form_for to wrap around
    authorize @obsession
    @themes = policy_scope(Theme) # @themes stores all OCD themes so user can select which existing theme their new obsession pertains to
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
    @themes = policy_scope(Theme)
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

    def require_obsessions # this method is called before obsessions#index
      if policy_scope(Obsession).empty? # If there are no obsessions to view
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
