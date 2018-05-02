module ThemesHelper
  def tally_popularity(theme)
    if theme.obsessions_per_theme == 0
      "No patients are currently obsessing about \"#{theme.name}.\""
    else
      <<-HEREDOC
      #{theme.prevalence_in_patients} #{'patient'.pluralize(theme.prevalence_in_patients)}
      #{'is'.pluralize(theme.prevalence_in_patients)} obsessing about #{theme.name}, in which
      #{theme.obsessions_per_theme} #{'obsession'.pluralize(theme.obsessions_per_theme)}
      #{'is'.pluralize(theme.obsessions_per_theme)} classified.
      HEREDOC
    end
  end
end
