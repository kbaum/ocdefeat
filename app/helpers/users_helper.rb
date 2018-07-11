module UsersHelper
  def show_patients(users)
    if users.empty?
      content_tag(:small, "0 patients") + content_tag(:br)
    else
      render partial: "users_ul", locals: { users: users }
    end
  end

  def symptoms_in(users) # argument is AR::Relation of a therapist's patients
    if users.all? {|user| user.obsessions.empty?} # If none of the therapist's patients have obsessions
      content_tag(:small, "All of your patients are asymptomatic and nonobsessive!")
    elsif users.patients_nonobsessive.empty? && users.patients_obsessive_but_symptomless.empty? # All of the therapist's patients have obsessions, and all of these obsessions have symptoms
      content_tag(:small, "All of your OCD patients are physically symptomatic.")
    elsif users.patients_nonobsessive.empty? && users.symptomatic.empty? # # All of the therapist's patients have obsessions, but none of these obsessions have symptoms
      content_tag(:small, "None of your OCD patients is physically symptomatic.")
    end
  end

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
end
