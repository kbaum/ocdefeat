class ThemesController < ApplicationController
  def new
    @theme = Theme.new # instance for form_for to wrap around
    authorize @theme
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
    @themes = policy_scope(Theme) # Theme.all
  end

  def destroy # DELETE request to "/themes/:id" maps to themes#destroy
    @theme = Theme.find(params[:id])
    authorize @theme
    theme_name = @theme.name
    @theme.destroy
    redirect_to themes_path, notice: "The OCD theme \"#{theme_name}\" has been deleted!"
  end

  private

    def theme_params
      params.require(:theme).permit(:name, :description)
    end
end
