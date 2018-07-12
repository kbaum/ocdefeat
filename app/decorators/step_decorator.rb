class StepDecorator < ApplicationDecorator
  def position_in_plan
    plan.steps.find_index(step).to_i + 1
  end

  def display_discomfort
    if discomfort_degree.nil?
      if current_user.patient?
        link_to("Rate your discomfort", edit_step_path(step)) << " when performing this step."
      elsif current_user.therapist? && plan.user.in?(current_user.counselees)
        "Not yet rated"
      end
    else
      discomfort_degree
    end
  end
end
