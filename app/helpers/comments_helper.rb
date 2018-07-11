module CommentsHelper
  def reassurance_gerunds
    if current_user.patient?
      "seeking"
    elsif current_user.therapist?
      "providing"
    end
  end
end
