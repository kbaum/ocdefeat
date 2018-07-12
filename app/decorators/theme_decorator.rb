class ThemeDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all

  def popularity
    if obsessions.empty?
      "No patients are currently obsessing about \"#{name}.\""
    else
      <<-HEREDOC
      #{pluralize(prevalence_in_patients, 'patient')}
      #{'is'.pluralize(prevalence_in_patients)} obsessing about #{name},
      in which #{pluralize(obsessions.count, 'obsession')}
      #{'is'.pluralize(obsessions.count)} classified.
      HEREDOC
    end
  end
end
