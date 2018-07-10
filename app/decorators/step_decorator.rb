class StepDecorator < Draper::Decorator
  delegate_all

  def last_updated
    updated_at.strftime("Last modified on %A, %B %e, at %l:%M %p")
  end
end
