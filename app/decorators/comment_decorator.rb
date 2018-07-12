class CommentDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all

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
end
