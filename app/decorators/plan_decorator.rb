class PlanDecorator < SimpleDelegator
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
end
