module PlansHelper

  def status_of(plan)
    if plan.steps.empty?
      "Development Phase (must add steps)"
    else
      plan.done? ? "Finished! (Fully performed and desensitization achieved)" : "Unfinished (must execute all ERP exercises)"
    end
  end

  def planner
    @finished ? "#{@finished.first.designer.name}" : "#{@unfinished.first.designer.name}"
  end

end
