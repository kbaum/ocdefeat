class ThemesController < ApplicationController
  def index
    @themes = Theme.all
    authorize @themes
  end
end
