module ObsessionsHelper
  def originated_on(obsession)
    obsession.created_at.strftime("%A, %B %e, %Y, at %l:%M %p")
  end
end
