module ThemesHelper
  def tally_popularity(theme)
    if theme.obsessions_per_theme == 0
      "No patients are currently obsessing about \"#{theme.name}.\""
    else
    end
  end
end
