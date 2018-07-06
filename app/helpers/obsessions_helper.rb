module ObsessionsHelper
  def filter_obsessions_header
    if current_user.patient?
      content_tag(:h4, "Filter Your Obsessions by...")
    elsif current_user.therapist?
      content_tag(:h4, "Filter Your Patients' Obsessions by...")
    end
  end

  def placefill_search
    if current_user.patient?
      "Take a moment to introspect. Search your thoughts..."
    elsif current_user.therapist?
      "Search thoughts containing..."
    end
  end

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
