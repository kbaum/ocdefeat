module NotesHelper
  def label_note
    if current_user.therapist?
      "Give this patient some therapy pointers:"
    elsif current_user.patient?
      "Voice your concerns to a counselor:"
    end
  end
end
