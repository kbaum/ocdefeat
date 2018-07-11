module CommentsHelper
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
