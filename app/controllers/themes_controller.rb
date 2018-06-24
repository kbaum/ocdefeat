class ThemesController < ApplicationController
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
    themes = policy_scope(Theme) # Theme.all
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
