module StepsHelper

  def div_class_for_step(step)
    "completed" if step.complete?
  end

  def div_for_step(step)
    div_for(step, class: div_class_for_step(step)) do
      yield
    end
  end

  def set_step_status(step)
    form_for([step.plan, step]) do |f|
      f.label :status, "Completed Exercise?"
      f.check_box :status, :class => "toggle", :checked => step.complete?
    end
  end

end

# Explanation of #div_class_for_step(step):
# Calling #complete? on step instance returns true if status attribute value of step instance = 1
# If the step is complete (i.e. its status attribute = 1), then method returns the string "completed"
# which becomes the class attribute value of the div for the step -- <div class="completed">
# This is how we mark a step of the ERP plan as completed with a strike-through

# Explanation of #div_for_step(step):
# I'm create a <div> for the step record (instance)
# the string class attribute value of this <div> is the result of calling #div_class_for_step(step)
# Then we yield to the block. We end up in app/views/steps/_step_div.html.erb partial file,
# where #div_for_step(step) is called and passed a block, and the code in that block is executed

# Explanation of #set_step_status(step):
# We are submitting a form with some JS to change the status of a step to mark it as complete when we click
# Use nested resource form (with array)- we want to build a form_for this step of this plan
# We want to submit a form via a PUT/PATCH request to "/plans/:plan_id/steps/:id" routed to #update action of StepsController
# So the URL attribute of the form_for helper method is #plan_step_path(plan_instance, step_instance) - returns "/plans/:plan_id/steps/:id"
# But with the nested resource form, we don't have to specify the url attribute of form_for
# b/c Rails can guess the URL based on the object type of the 2 instances
# and we don't have to tell it the method is PATCH - Rails can guess this b/c the step of the plan is saved to the DB
# |f| is the FormBuilder object given to us when we called form_for.
# Inside of this form builder is an object which refers to the step that we're building the form for.
# We're telling it that we want to build a checkbox for the status attribute of this step,
# I want to give that checkbox a class attribute value of "toggle"
# and the checked attribute of the checkbox should be true if the step is complete (#complete? called on step returns true if step's status = 1)
