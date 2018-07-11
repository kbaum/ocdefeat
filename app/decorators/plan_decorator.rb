class PlanDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def present_plans_header
    content_tag(:h4, current_user.patient? ? "Filter Your ERP Plans by..." : "Filter Your Patients' ERP Plans by...")
  end

  def present_progress
    if finished?
      "Accomplished! (Fully implemented and marked as finished)"
    else
      if steps.empty?
        "Preliminary Design (Lacks steps)"
      else
        if steps.all? {|step| step.completed?}
          "Development or Pending Submission (Fully performed but not marked finished)"
        else
          "Development or Implementation (Contains at least one incomplete step)"
        end
      end
    end
  end

  def show_strategy
    flooded? ? "Flooding" : "Graded Exposure"
  end

  def uncover_why_unachieved
    if steps.empty?
      "A plan can only be performed if it contains steps!"
    else
      "A plan can only be marked as finished if all of its steps are completed!"
    end
  end

  def add_or_perform_steps
    steps.empty? ? "Delineate the steps to be taken" : "Execute exposure exercises"
  end
end
