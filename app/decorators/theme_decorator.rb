class ThemeDecorator < ApplicationDecorator
  def popularity
    if obsessions.empty?
      "No patients reported obsessions that revolve around \"#{name}.\""
    else
      <<-HEREDOC
      #{pluralize(prevalence_in_patients, 'patient')}
      reported obsessions that revolve around \"#{name},\"
      a theme in which #{pluralize(obsessions.count, 'obsession')}
      #{'is'.pluralize(obsessions.count)} classified.
      HEREDOC
    end
  end
end
