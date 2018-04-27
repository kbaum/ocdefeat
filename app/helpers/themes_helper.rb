module ThemesHelper
  def num_obsessions_for(theme)
    theme.obsessions.count > 0 ? "This OCD theme currently contains #{pluralize(theme.obsessions.count, 'obsession')}." :
    "No obsessions currently pertain to this OCD theme!"
  end
end
