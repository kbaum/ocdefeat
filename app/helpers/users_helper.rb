module UsersHelper
  def demand_data(attribute_name) # argument is the string "severity" or "variant"
    if current_user.patient?
      content_tag(:div, class: "alert alert-warning", role: "alert") do
        content_tag(:label, "Please indicate your OCD #{attribute_name} in") +
        link_to(" your account information", edit_user_path(current_user), class: "alert-link") + "."
      end
    else
      content_tag(:div, class: "alert alert-info", role: "alert") do
        content_tag(:label, "#{attribute_name.capitalize}:") + " The patient has been instructed to comply by entering appropriate information."
      end
    end
  end

  def show_severity(user) # user is the patient whose profile is being viewed
    if user.severity.in?(%w[Mild Moderate Severe Extreme])
      content_tag(:h4, "#{user.name} vs. #{user.severity} OCD")
    else
      demand_data("severity")
    end
  end

  def vary_variant(user)
    if user.variant.in?(["Traditional", "Purely Obsessional", "Both"])
      content_tag(:label, "OCD Variant:") +
      case user.variant
      when "Traditional"
        " Traditional"
      when "Purely Obsessional"
        " Pure-O"
      when "Both"
        " Hybrid of Traditional and Pure-O"
      end
    else
      demand_data("variant")
    end
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
      "You designed"
    elsif current_user.therapist? || current_user.admin?
      "The patient designed"
    end
  end

  def panicky_patients
    if User.patients_overanxious.empty?
      content_tag(:label, "No patients reported obsessions that induce above-average anxiety levels.")
    else
      content_tag(:label, "Patients whose distress exceeds average anxiety level #{Obsession.average_anxiety_rating}") + ":" +
      content_tag(:ul) do
        User.patients_overanxious.each do |user|
          concat(content_tag(:li, link_to(user.name, user_path(user))))
        end
      end
    end
  end
end
