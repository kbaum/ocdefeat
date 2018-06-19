module PlansHelper
  def reason_why_unachieved(plan)
    plan.steps.empty? ? "A plan can only be performed if it contains steps!" : "A plan can only be marked as finished if all of its steps are completed!"
  end

  def add_or_perform_steps(plan)
    plan.steps.empty? ? "Delineate the steps to be taken" : "Execute exposure exercises" if plan
  end

  def status_of(plan)
    if plan.steps.empty?
      "In Development (must add steps)"
    elsif plan.finished?
      "Finished (fully performed and desensitization achieved)"
    else
      "Unfinished (must execute all ERP exercises)"
    end
  end

  def planner(accomplished, unaccomplished)
    accomplished.blank? ? "#{unaccomplished.first.user.name}" : "#{accomplished.first.user.name}"
  end

  def report(accomplished, unaccomplished)
    if accomplished && unaccomplished # If the patient has both finished AND unfinished plans
      "marked #{accomplished.count} ERP #{'plan'.pluralize(accomplished.count)} as finished and left #{unaccomplished.count} ERP #{'plan'.pluralize(unaccomplished.count)} unfinished."
    elsif accomplished.nil? # If the patient did NOT finish any ERP plans
      "failed to finish any ERP plans and left #{unaccomplished.count} ERP #{'plan'.pluralize(unaccomplished.count)} unfinished."
    elsif unaccomplished.nil? # If the patient only has finished ERP plans
      "achieved desensitization by implementing #{accomplished.count} ERP #{'plan'.pluralize(accomplished.count)} from start to finish!"
    end
  end

  def present_plans(plans)
    content_tag(:ul, class: "plans-ul") do
      plans.each do |plan|
        concat(content_tag(:li, link_to(plan.title, plan_path(plan))))
      end
    end
  end

end
