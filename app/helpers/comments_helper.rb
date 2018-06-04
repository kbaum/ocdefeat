module CommentsHelper
  def label_comment
    if current_user.therapist?
      "Give this patient some therapy pointers:"
    elsif current_user.patient?
      "Voice your concerns to a counselor:"
    end
  end

  def placefill_comment
    if current_user.therapist?
      "Add mental health tips..."
    elsif current_user.patient?
      "Tell me your troubles..."
    end
  end
end
