class CommentDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all

  def label
    if current_user.therapist?
      "Give the patient some therapy pointers to defeat this obsession"
    elsif current_user.patient?
      "Voice your concerns to a counselor about this obsession"
    end
  end
end
