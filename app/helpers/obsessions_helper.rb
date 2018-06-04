module ObsessionsHelper
  def originated_on(obsession)
    obsession.created_at.strftime("%A, %B %e, %Y, at %l:%M %p")
  end

  def rhyme_symptoms(obsession)
    if obsession.symptoms.blank?
      "until every last fear evaporates"
    else
      ", and symptoms such as #{obsession.symptoms} will dissipate"
    end
  end
end
