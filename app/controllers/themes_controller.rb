class ThemesController < ApplicationController
  before_action :set_theme, only: [:edit, :update, :destroy]

  def new
    @theme = Theme.new # instance for form_for to wrap around
    authorize @theme
  end

  def create
    # @theme = Theme.new(theme_params)
    @theme = current_user.themes.build(theme_params)
    authorize @theme

    if @theme.save
      redirect_to themes_path, flash: { success: "You created the OCD theme \"#{Theme.last.name}\" in which to classify your patients' obsessions!" }
    else
      flash.now[:alert] = "Notwithstanding your psychological expertise, your attempt to create a unique OCD theme was unsuccessful. Please try again."
      render :new
    end
  end

  def edit
    authorize @theme
  end

  def update
    authorize @theme
    if @theme.update_attributes(permitted_attributes(@theme))
      redirect_to themes_path, flash: { success: "You successfully modified the description of this OCD theme!" }
    else
      flash.now[:error] = "Your attempt to edit the description of this OCD theme was unsuccessful. Please try again."
      render :edit
    end
  end

  def index
    @themes = policy_scope(Theme) # Theme.all
  end

  def destroy # DELETE request to "/themes/:id" maps to themes#destroy
    theme = Theme.find(params[:id])
    authorize theme
    theme_name = theme.name
    theme.destroy
    redirect_to themes_path, flash: { success: "The OCD theme \"#{theme_name}\" was successfully deleted!" }
  end

  private
    def set_theme
      @theme = Theme.find(params[:id])
    end

    def theme_params
      params.require(:theme).permit(:name, :description)
    end
end
