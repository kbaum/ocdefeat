class ThemesController < ApplicationController
  before_action :require_themes, only: :index

  def index
    themes = policy_scope(Theme)
  end

  private

    def require_themes # private filter method called before themes#index
      themes = policy_scope(Theme)
      if themes.empty? # If there are no OCD themes
        redirect_to root_url, alert: "The Index of OCD Themes is currently empty."
      end
    end
end
