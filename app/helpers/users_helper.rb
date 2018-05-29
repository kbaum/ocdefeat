module UsersHelper
  def obsession_pronouns
    if current_user.patient?
      "You are currently conquering"
    elsif current_user.therapist? || current_user.admin?
      "The patient is currently conquering"
    end
  end

  def plan_pronouns
    if current_user.patient?
      "You have designed"
    elsif current_user.therapist? || current_user.admin?
      "The patient has designed"
    end
  end
end
