module PlansHelper
  def progress(plan)
    if plan.finished?
      "Accomplished! (Fully implemented and marked as finished)"
    else
      if plan.steps.empty?
        "Preliminary Design (Lacks steps)"
      else
        if plan.steps.all? {|step| step.complete?}
          "Development or Pending Submission (Fully performed but not marked finished)"
        else
          "Development or Implementation (Contains at least one incomplete step)"
        end
      end
    end
  end

  def treatment_approach(plan)
    plan.flooded? ? "Flooding" : "Graded Exposure"
  end

  def reason_why_unachieved(plan)
    plan.steps.empty? ? "A plan can only be performed if it contains steps!" : "A plan can only be marked as finished if all of its steps are completed!"
  end

  def add_or_perform_steps(plan)
    plan.steps.empty? ? "Delineate the steps to be taken" : "Execute exposure exercises"
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
