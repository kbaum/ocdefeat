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
end
