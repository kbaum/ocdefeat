module UsersHelper
  def anxiety_amount(user)
    Obsession.average_anxiety_by_patient[user.name].nil? ?
    "Not anxious" : Obsession.average_anxiety_by_patient[user.name].to_i
  end

  def clinical_features(user)
    user.in?(User.symptomatic) ? "Symptomatic" : "Asymptomatic"
  end

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
    if User.patients_overanxious.empty?
      content_tag(:p, "No patients reported obsessions that induce above-average anxiety levels.")
    else
      content_tag(:ul) do
        User.patients_overanxious.each do |user|
          concat(content_tag(:li, link_to(user.name, user_path(user))))
        end
      end
    end
  end

  def vary_variant(user)
    case user.variant
    when "Traditional"
      "Traditional"
    when "Purely Obsessional"
      "Pure-O"
    when "Both"
      "Hybrid of Traditional and Pure-O"
    end
  end

  def sort_severity_diagnosees(severity)
    content_tag(:p) do
      content_tag(:strong, "#{severity}ly Obsessive Patients:")
    end +
    if User.by_ocd_severity(severity).empty?
      content_tag(:p) do
        content_tag(:em, "No patients were diagnosed with #{severity} OCD.")
      end
    else
      render partial: "users_ul", locals: { users: User.by_ocd_severity(severity) }
    end
  end

  def sort_variant_diagnosees(variant)
    content_tag(:p) do
      content_tag(:strong, "Patients who Perform #{variant} Types of Rituals:")
    end +
    if User.by_ocd_variant(variant).empty?
      content_tag(:p) do
        content_tag(:em, "No patients perform #{variant.downcase} types rituals.")
      end
    else
      render partial: "users_ul", locals: { users: User.by_ocd_variant(variant) }
    end
  end
end
