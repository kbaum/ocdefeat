class ThemesController < ApplicationController
  def index
    @themes = policy_scope(Theme)
  end
end
