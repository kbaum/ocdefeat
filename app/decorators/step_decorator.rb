class StepDecorator < SimpleDelegator
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  def last_updated
    updated_at.strftime("Last modified on %A, %B %e, at %l:%M %p")
  end

  def display_discomfort(user)
    if discomfort_degree.nil?
      if user.patient?
        link_to("Rate your discomfort", edit_step_path(__getobj__)) << " when performing this step."
      elsif user.therapist? && plan.user.in?(user.counselees)
        "Not yet rated"
      end
    else
      discomfort_degree
    end
  end

  def present_position_in_plan
    plan.steps.find_index(__getobj__).to_i + 1
  end
end
