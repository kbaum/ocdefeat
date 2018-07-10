class StepDecorator < SimpleDelegator
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  def last_updated
    updated_at.strftime("Last modified on %A, %B %e, at %l:%M %p")
  end
end
