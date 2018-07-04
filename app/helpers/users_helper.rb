module UsersHelper
  def symptoms_in(users) # argument is AR::Relation of a therapist's patients
    if users.all? {|user| user.obsessions.empty?} # If none of the therapist's patients have obsessions
      content_tag(:small, "All of your patients are asymptomatic since none of them are obsessing!")
    elsif users.patients_nonobsessive.empty? && users.patients_obsessive_but_symptomless.empty? # All of the therapist's patients have obsessions, and all of these obsessions have symptoms
      content_tag(:small, "All of your OCD patients are physically symptomatic.")
    elsif users.patients_nonobsessive.empty? && users.symptomatic.empty? # # All of the therapist's patients have obsessions, but none of these obsessions have symptoms
      content_tag(:small, "None of your OCD patients is physically symptomatic.")
    end
  end

  def unexposed(users) # argument is AR::Relation of a therapist's patients
    if users.unexposed_to_obsession.empty?
      content_tag(:small, "All of your patients designed at least one ERP plan to target each of their obsessions!")
    else
      content_tag(:small, "#{sv_agreement(users.unexposed_to_obsession)} unexposed to an obsession, having reported at least one obsession that lacks ERP plans.")
    end
  end

  def planning_or_practicing(users) # argument is AR::Relation of a therapist's patients
    if users.patients_planning_or_practicing_erp.empty?
      content_tag(:small, "None of your patients are currently designing or implementing ERP plans.")
    else
      content_tag(:small, "#{sv_agreement(users.patients_planning_or_practicing_erp)} currently developing or performing an ERP plan.")
    end
  end

  def finished_planning(users) # argument is AR::Relation of a therapist's patients
    if users.with_finished_plan.empty?
      content_tag(:small, "None of your patients marked an ERP plan as finished.")
    else
      content_tag(:small, "#{plural_inflection(users.with_finished_plan)} marked at least one ERP plan as finished!")
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
    if current_user.therapist? && policy_scope(User).patients_overanxious.empty?
      content_tag(:label, "None of your patients reported obsessions that induce above-average anxiety levels.")
    elsif current_user.therapist?
      content_tag(:label, "Patients with above-average anxiety levels") + ":" +
      content_tag(:ul) do
        policy_scope(User).patients_overanxious.each do |user|
          concat(content_tag(:li, link_to(user.name, user_path(user))))
        end
      end
    end
  end
end
