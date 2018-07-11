module CommentsHelper
  def placefill_comment
    if current_user.therapist?
      "Add mental health tips..."
    elsif current_user.patient?
      "Feel free to vent here..."
    end
  end

  def label_submit_btn
    if current_user.therapist?
      "Share Your Advice"
    elsif current_user.patient?
      "Share Your Troubles"
    end
  end

  def reassurance_gerunds
    if current_user.patient?
      "seeking"
    elsif current_user.therapist?
      "providing"
    end
  end
end
