module UsersHelper
  def obsession_pronouns
    if current_user.patient?
      "You are currently conquering"
    elsif current_user.therapist?
      "The patient is currently conquering"
    end
  end

  def plan_pronouns
    if current_user.patient?
      "You have designed"
    elsif current_user.therapist?
      "The patient has designed"
    end
  end

  def select_severity(user)
    if current_user.patient?
      "Your role was recently changed to patient. Do you have mild, moderate, severe or extreme OCD?"
    elsif current_user.therapist? || current_user.admin?
      "Now that #{user.name}'s role was changed, this patient must report a valid OCD severity."
    end
  end

  def vary_variant(user)
    if current_user.patient?
      "Your role was recently changed to patient. Were you diagnosed with Traditional OCD, Pure-O or both variants of the disorder?"
    elsif current_user.therapist? || current_user.admin?
      "Now that #{user.name}'s role was changed, this patient must report a valid OCD variant."
    end
  end
end
