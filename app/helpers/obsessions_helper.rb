module ObsessionsHelper
  def display_obsessions(obsessions)
    unless obsessions.nil?
      content_tag(:ul) do
        obsessions.each do |obsession|
          concat(content_tag(:li, link_to_unless(current_user.admin?, obsession.intrusive_thought, obsession_path(obsession))))
        end
      end
    end
  end

  def originated_on(obsession)
    obsession.created_at.strftime("%A, %B %e, %Y, at %l:%M %p")
  end

  def rhyme_symptoms(obsession)
    if obsession.symptoms.blank?
      " until every single fear evaporates"
    else
      ", and symptoms such as #{obsession.symptoms} will dissipate"
    end
  end
end
