module NotesHelper
  def label_note
    if current_user.therapist?
      "Give this patient some therapy pointers:"
    elsif current_user.patient?
      "Voice your concerns to a counselor:"
    end
  end

  def placefill_note
    if current_user.therapist?
      "Add mental health tips..."
    elsif current_user.patient?
      "Tell me your troubles..."
    end
  end

  def label_submit_btn
    if current_user.therapist?
      "Share Your Advice"
    elsif current_user.patient?
      "Share Your Troubles"
    end
  end
end
