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

  def panicky_patients
    if User.patients_very_unnerved.empty?
      content_tag(:p, "Overall, patients did not report debilitating degrees of OCD distress. The anxiety generated by each OCD trigger does not exceed level 5.")
    else
      content_tag(:ul) do
        User.patients_very_unnerved.each do |user|
          concat(content_tag(:li, user.name))
        end
      end
    end
  end
end
