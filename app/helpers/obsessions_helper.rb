module ObsessionsHelper
  def obsessions_header
    text = current_user.patient? ? "Filter Your Obsessions by..." : "Filter Your Patients' Obsessions by..."
    content_tag(:h4, "#{text}")
  end

  def placefill_search
    current_user.patient? ? "Take a moment to introspect. Search your thoughts..." : "Search thoughts containing..."
  end

  def display_obsessions(obsessions)
    unless obsessions.nil?
      content_tag(:ul) do
        obsessions.each do |obsession|
          concat(content_tag(:li, link_to_unless(current_user.admin?, obsession.decorate.hypotheticalize, obsession_path(obsession))))
        end
      end
    end
  end
end
