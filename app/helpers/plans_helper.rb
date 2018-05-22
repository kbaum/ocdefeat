module PlansHelper

  def status_of(plan)
    if plan.steps.empty?
      "In Development (must add steps)"
    elsif plan.done?
      "Finished (fully performed and desensitization achieved)"
    else
      "Unfinished (must execute all ERP exercises)"
    end
  end

  def planner(finished, unfinished)
    finished.blank? ? "#{unfinished.first.designer.name}" : "#{finished.first.designer.name}"
  end

  def report(finished, unfinished)
    if finished && unfinished # If the patient has both finished AND unfinished plans
      "finished #{finished.count} ERP #{'plan'.pluralize(finished.count)} and left #{unfinished.count} ERP #{'plan'.pluralize(unfinished.count)} unfinished."
    elsif finished.nil? # If the patient did NOT finish any ERP plans
      "failed to finish any ERP plans and left #{unfinished.count} ERP #{'plan'.pluralize(unfinished.count)} unfinished."
    elsif unfinished.nil? # If the patient only has finished ERP plans
      "achieved desensitization by implementing #{finished.count} ERP #{'plan'.pluralize(finished.count)} from start to finish!"
    end
  end

  def list_plans(plans)
    content_tag(:ul, class: "plans-ul") do
      plans.each do |plan|
        concat(content_tag(:li, link_to(plan.title, plan_path(plan))))
      end
    end
  end

end
