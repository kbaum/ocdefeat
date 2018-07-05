module ThemesHelper
  def tally_popularity(theme)
    if theme.obsessions_per_theme == 0
      "No patients are currently obsessing about \"#{theme.name}.\""
    else
      <<-HEREDOC
      #{pluralize(theme.prevalence_in_patients, 'patient')}
      #{'is'.pluralize(theme.prevalence_in_patients)} obsessing about #{theme.name},
      in which #{pluralize(theme.obsessions_per_theme, 'obsession')}
      #{'is'.pluralize(theme.obsessions_per_theme)} classified.
      HEREDOC
    end
  end
end
