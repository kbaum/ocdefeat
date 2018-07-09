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

  def uncover_why_unachieved
    steps.empty? ? "A plan can only be performed if it contains steps!" : "A plan can only be marked as finished if all of its steps are completed!"
  end
end
