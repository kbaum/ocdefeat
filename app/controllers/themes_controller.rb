class ThemesController < ApplicationController
  before_action :require_themes, only: :index

  def index
    themes = policy_scope(Theme)
    patients = User.where(role: 1)

    if !params[:prevalence].blank? # Filtering OCD themes by prevalence of theme among patients
      primary_prevalence = themes.first.prevalence_in_patients # stores the number of distinct users obsessing about the 1st theme
      if patients.empty? # If there are no patients
        flash.now[:alert] = "OCD themes cannot be ordered by prevalence in patients, as there are currently no patients!"
      elsif patients.all? {|patient| patient.obsessions.empty?} # There are patients but they don't have obsessions
        flash.now[:alert] = "OCD themes cannot be ordered by prevalence in patients, as patients currently have no obsessions!"
      elsif themes.all? {|theme| theme.prevalence_in_patients == 0} # If none of the patients' obsessions pertain to any of the themes
        flash.now[:alert] = "Patients' obsessions are not classified in any OCD theme."
      elsif themes.count == 1 # There is only 1 OCD theme with a prevalence in patients that is > 0
        @theme = themes.first
        flash.now[:notice] = "\"#{@theme.name}\" is the only theme currently listed, and it supplies content for #{@theme.prevalence_in_patients} #{'patient'.pluralize(@theme.prevalence_in_patients).possessive} obsessions."
      elsif themes.all? {|theme| theme.prevalence_in_patients == primary_prevalence} # If there is more than 1 theme, the prevalence in patients is not 0, and the same number of distinct users obsesses about each theme
        flash.now[:alert] = "All OCD themes are equally prevalent among patients; #{primary_prevalence} #{'patient'.pluralize(primary_prevalence)} #{'is'.pluralize(primary_prevalence)} obsessing about each theme."
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
        flash.now[:notice] = "\"#{@theme.name},\" the only OCD theme currently listed, contains #{@theme.obsessions.count} " << "#{'obsession'.pluralize(@theme.obsessions.count)}."
      elsif themes.all? {|theme| theme.obsessions.count == obsession_count_one} # If all themes have the same number of obsessions classified in them
        flash.now[:alert] = "OCD themes cannot be ordered by number of obsessions per theme, as all OCD themes contain #{obsession_count_one} " << "#{'obsession'.pluralize(obsession_count_one)}!"
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

  private

    def require_themes # private method called before themes#index ensures that there is at least 1 theme to view index
      themes = policy_scope(Theme)
      if themes.empty? # If there are no OCD themes
        redirect_to root_url, alert: "The Index of OCD Themes is currently empty."
      end
    end
end
