module ObsessionsHelper
  def obsessions_header
    text = current_user.patient? ? "Filter Your Obsessions by..." : "Filter Your Patients' Obsessions by..."
    content_tag(:h4, "#{text}")
  end

  def placefill_search
    current_user.patient? ? "Take a moment to introspect. Search your thoughts..." : "Search thoughts containing..."
  end

  def display_obsessions(obsessions) # Each obsession in this collection must be an ObsessionDecorator object
    if obsessions.nil? || obsessions.empty?
      content_tag(:small, content_tag(:mark, "No obsessions were found."))
    else
      content_tag(:ul) do
        obsessions.each do |obsession|
          concat(content_tag(:li, link_to_unless(current_user.admin?, obsession.hypotheticalize, obsession_path(obsession))))
        end
      end
    end
  end
end
# obsessions.nil? => true if patient_obsessions is not set, or if obsessions is not set = filter_by_date.decorate when obsessions are not found for filter
# obsessions.empty? => true from ObsessionFinder query object
