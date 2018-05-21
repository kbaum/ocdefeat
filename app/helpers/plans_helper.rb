module PlansHelper

  def status_of(plan)
    if plan.steps.empty?
      "In Development (must add steps)"
    else
      plan.done? ? "Finished! (Fully performed and desensitization achieved)" : "Unfinished (must execute all ERP exercises)"
    end
  end

  def planner(finished, unfinished)
    finished.blank? ? "#{unfinished.first.designer.name}" : "#{finished.first.designer.name}"
  end

  def report(finished, unfinished)
    if finished && unfinished # If the patient has both finished AND unfinished plans
      "finished #{finished.to_ary.count} ERP #{'plan'.pluralize(finished.to_ary.count)} and left #{unfinished.count} ERP #{'plan'.pluralize(unfinished.count)} unfinished."
    elsif finished.nil? # If the patient did NOT finish any ERP plans
      "failed to finish any ERP plans and left #{unfinished.count} ERP #{'plan'.pluralize(unfinished.count)} unfinished."
    elsif unfinished.nil? # If the patient only has finished ERP plans
      "achieved desensitization by implementing #{finished.to_ary.count} ERP #{'plan'.pluralize(finished.to_ary.count)} from start to finish!"
    end
  end

end
