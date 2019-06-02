module PlansHelper
  def present_plans_header
    content_tag(:h4, current_user.patient? ? "Filter Your ERP Plans by..." : "Filter Your Patients' ERP Plans by...")
  end

  def display_plans(plans)
    if plans.nil? || plans.empty?
      content_tag(:small, "0") + content_tag(:br)
    else
      content_tag(:ul) do
        plans.each do |plan|
          concat(content_tag(:li, link_to_unless(current_user.admin?, plan.title.titleize, plan_path(plan))))
        end
      end
    end
  end

  def tip_for_plan_improvement(unfinished_plans)
    if !unfinished_plans.empty? # The patient has plans that are left unfinished
      tip =
        if unfinished_plans.with_steps.empty? # If all unfinished plans lack steps
          "You must delineate the steps of every unfinished plan"
        elsif unfinished_plans.stepless.empty? # If all unfinished plans have steps
          "You must mark all steps as complete and then mark each plan as finished"
        end
      content_tag(:small, "*#{tip}*") if tip
    end
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
end
