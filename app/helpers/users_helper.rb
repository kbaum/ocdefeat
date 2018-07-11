module UsersHelper
  def present_patients(patients)
    if current_user.therapist? && patients.all? {|patient| patient.counselor == current_user}
      if patients.empty?
        content_tag(:small, "0") + content_tag(:br)
      else
        render partial: "users_ul", locals: { users: patients }
      end
    end
  end

  def summarize_symptoms
    if current_user.therapist?
      symptoms_summary =
        if current_user.counselees.all? {|counselee| counselee.obsessions.empty?} # If none of the therapist's patients have obsessions
          "All of your patients are asymptomatic and nonobsessive!"
        elsif current_user.counselees.patients_nonobsessive.empty? && current_user.counselees.patients_obsessive_but_symptomless.empty? # All of the therapist's patients have obsessions, and all of these obsessions have symptoms
          "All of your OCD patients are physically symptomatic."
        elsif current_user.counselees.patients_nonobsessive.empty? && current_user.counselees.symptomatic.empty? # All of the therapist's patients have obsessions, but none of these obsessions have symptoms
          "None of your OCD patients is physically symptomatic."
        end
      content_tag(:small, symptoms_summary)
    end
  end
end
