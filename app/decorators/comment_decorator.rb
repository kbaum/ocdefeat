class CommentDecorator < ApplicationDecorator  
  def label
    if current_user.patient?
      "Voice your concerns about this obsession"
    else
      "Give the patient some therapy pointers to defeat this obsession"
    end
  end

  def placefill
    current_user.patient? ? "Feel free to vent here..." : "Add mental health tips..."
  end

  def submit_btn_text
    "Share Your " << (current_user.patient? ? "Troubles" : "Advice")
  end

  def reassurance_gerunds
    current_user.patient? ? "seeking" : "providing"
  end

  def creation_message
    if current_user.patient?
      "Thank you for reaching out to your therapist to express your concerns!"
    else
      "Thank you for sharing your advice about overcoming this obsession!"
    end
  end
end
