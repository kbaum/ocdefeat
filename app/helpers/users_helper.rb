module UsersHelper
  def symptoms_in(users) # argument is AR::Relation of a therapist's patients
    if users.all? {|user| user.obsessions.empty?} # If none of the therapist's patients have obsessions
      content_tag(:small, "All of your patients are asymptomatic and nonobsessive!")
    elsif users.patients_nonobsessive.empty? && users.patients_obsessive_but_symptomless.empty? # All of the therapist's patients have obsessions, and all of these obsessions have symptoms
      content_tag(:small, "All of your OCD patients are physically symptomatic.")
    elsif users.patients_nonobsessive.empty? && users.symptomatic.empty? # # All of the therapist's patients have obsessions, but none of these obsessions have symptoms
      content_tag(:small, "None of your OCD patients is physically symptomatic.")
    end
  end
end
