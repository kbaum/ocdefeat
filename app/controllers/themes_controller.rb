class ThemesController < ApplicationController
  before_action :require_themes, only: :index

  def new
    @theme = Theme.new # instance for form_for to wrap around
  end

  def create
    @theme = Theme.new(theme_params)
    authorize @theme

    if @theme.save
      flash.now[:notice] = "You created the OCD theme \"#{Theme.last.name}\" in which to classify your patients' obsessions!"
    else
      flash.now[:alert] = "Notwithstanding your psychological expertise, your attempt to create a unique OCD theme was unsuccessful. Please try again."
      render :new
    end
  end

  def index
    themes = policy_scope(Theme)
    @new_theme = Theme.new # instance for form_for to wrap around when therapist creates new theme on themes index page
    patients = User.patients

    if !params[:prevalence].blank? # Filtering OCD themes by prevalence of theme among patients
      primary_prevalence = themes.first.prevalence_in_patients # stores the number of distinct users obsessing about the 1st theme
      if patients.empty? # If there are no patients
        flash.now[:alert] = "OCD themes cannot be ordered by prevalence in patients, as there are currently no patients!"
      elsif patients.all? {|patient| patient.obsessions.empty?} # There are patients but they don't have obsessions
        flash.now[:alert] = "OCD themes cannot be ordered by prevalence in patients, as patients currently have no obsessions!"
      elsif themes.all? {|theme| theme.prevalence_in_patients == 0} # If none of the patients' obsessions pertain to any of the themes
        flash.now[:alert] = "Patients' obsessions are not classified in any OCD theme."
      elsif themes.count == 1 # There is only 1 OCD theme with a prevalence in patients that is > 0
        @themes = themes
        flash.now[:notice] = "\"#{@themes.first.name}\" is the only theme currently listed, and it supplies content for #{@themes.first.prevalence_in_patients} #{'patient'.pluralize(@themes.first.prevalence_in_patients).possessive} obsessions."
      elsif themes.all? {|theme| theme.prevalence_in_patients == primary_prevalence} # If there is more than 1 theme, the prevalence in patients is not 0, and the same number of distinct users obsesses about each theme
        flash.now[:alert] = "All OCD themes are equally prevalent in patients; #{primary_prevalence} #{'patient'.pluralize(primary_prevalence)} #{'is'.pluralize(primary_prevalence)} obsessing about each theme."
      elsif params[:prevalence] == "Least to Most Prevalent"
        @themes = themes.least_to_most_prevalent
        flash.now[:notice] = "OCD themes are ordered from least to most prevalent in patients!"
      else
        @themes = themes.most_to_least_prevalent
        flash.now[:notice] = "OCD themes are ordered from most to least prevalent in patients!"
      end
    elsif !params[:obsession_count].blank? # Filtering OCD themes by the number of obsessions classified in theme
      obsession_count_one = themes.first.obsessions.count
      if Obsession.all.empty? # if there are no obsessions at all
        flash.now[:alert] = "OCD Themes cannot be ordered by obsession count, as there are currently no obsessions!"
      elsif themes.all? {|theme| theme.obsessions.empty?} # If every theme has no obsessions
        flash.now[:alert] = "No obsessions are classified in any OCD theme."
      elsif themes.count == 1 # There is 1 OCD theme, in which at least 1 obsession is classified
        @theme = themes.first
        flash.now[:notice] = "#{@theme.obsessions_per_theme} #{'obsession'.pluralize(@theme.obsessions_per_theme)} #{'is'.pluralize(@theme.obsessions_per_theme)} classified in \"#{@theme.name},\" the only OCD theme currently listed."
      elsif themes.all? {|theme| theme.obsessions.count == obsession_count_one} # If all themes have the same number of obsessions classified in them
        flash.now[:alert] = "OCD themes cannot be ordered by number of obsessions per theme, as #{obsession_count_one} #{'obsession'.pluralize(obsession_count_one)} #{'is'.pluralize(obsession_count_one)} classified in each OCD theme!"
      elsif params[:obsession_count] == "Least to Most Obsessions per Theme"
        @themes = themes.least_to_most_obsessions
        flash.now[:notice] = "OCD themes are ordered by least to most obsessions per theme!"
      else # Filtering themes by Most to Least Obsessions per Theme
        @themes = themes.most_to_least_obsessions
        flash.now[:notice] = "OCD themes are ordered by most to least obsessions per theme!"
      end
    else # No filter was chosen
      @themes = themes # stores all themes
    end
  end

  def destroy
    theme_name = Theme.find(params[:id]).name
    Theme.find(params[:id]).destroy
    redirect_to themes_path, notice: "The OCD theme \"#{theme_name}\" has been deleted!"
  end

  private

    def require_themes # private method called before themes#index ensures that there is at least 1 existing theme when patient/admin views index
      if Theme.all.empty? # If there are no OCD themes
        if current_user.therapist?
          flash.now[:alert] = "The Index of OCD Themes is currently empty. Add a new theme below!"
        else
          redirect_to root_url, alert: "The Index of OCD Themes is currently empty."
        end
      end
    end

    def theme_params
      params.require(:theme).permit(:name, :description)
    end
end
