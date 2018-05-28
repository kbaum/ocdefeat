module UsersHelper
  def obsession_pronouns
    if current_user.patient?
      "You are"
    elsif current_user.therapist?
      "The patient is"
    end
  end

  def plan_pronouns
    if current_user.patient?
      "You have designed"
    elsif current_user.therapist?
      "The patient has designed"
    end
  end
end
