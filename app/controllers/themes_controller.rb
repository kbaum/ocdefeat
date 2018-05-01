class ThemesController < ApplicationController
  before_action :require_themes, only: :index

  def index
    themes = policy_scope(Theme)
    if !params[:prevalence].blank? # Filtering OCD themes by prevalence of theme among patients
      primary_prevalence = themes.first.prevalence_in_patients # stores the number of distinct users obsessing about the 1st theme
      if themes.all? {|theme| theme.prevalence_in_patients == primary_prevalence} # If the same number of distinct users obsesses about each theme
        flash.now[:alert] = "All OCD themes are equally prevalent among patients; each theme preoccupies #{primary_prevalence} patient(s)."
      elsif params[:prevalence] == "Least to Most Prevalent"
        @themes = themes.least_to_most_prevalent
      else
        @themes = themes.most_to_least_prevalent
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
