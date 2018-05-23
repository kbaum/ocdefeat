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
      f.check_box :status, :class => "toggle", :checked => step.complete?
    end
  end

  def last_updated(step)
    step.updated_at.strftime("Last modified on %A, %B %e, at %l:%M %p")
  end

  def position_in_plan(step)
    step.plan.steps.find_index(step).to_i + 1
  end

  def display_discomfort(step)
    if step.discomfort_degree.nil?
      if current_user.patient?
        link_to("Rate your degree of discomfort", edit_plan_step_path(step.plan, step)) << " when performing this ERP exercise!"
      elsif current_user.therapist? || current_user.admin?
        "Not yet rated."
      end
    else
      "#{step.discomfort_degree}"
    end
  end


  def show_status(step)
    if step.incomplete?
      if current_user.patient?
        if step.discomfort_degree.nil?
          "You must rate your discomfort when performing this step before you can mark it as complete!"
        else
          "Check the box below once you finish practicing this exposure exercise!"
        end
      elsif current_user.therapist? || current_user.admin?
        "Not yet completed."
      end
    else
      "Completed!"
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
# How checkboxes work in the browser:
# When you uncheck a checkbox, the browser does not submit any data, but when you check a checkbox, the browser does submit data
# Rails generates 2 <input>s (the first is a hidden <input>).
# In the event that you uncheck the checked checkbox,
# the hidden input field with a value of 0 will still submit
# If you DO check the checkbox, then the <input> with the same name attribute value of "step[status]"
# will overwrite the value of the always-submitted hidden step[status] <input> of value 0
# changing it from 0 to 1

# Explanation of #last_updated(step)
# The updated_at attribute of a step instance is something like "2018-04-11 18:09:52"
# strftime(*args) formats date according to the directives in the given format string.
# The directives begins with a percent (%) character.
# Any text not listed as a directive will be passed through to the output string.
# So using strftime, "Last modified on %A, %B %e, at %l:%M %p"
# %A - The full weekday name ("Wednesday")
# %B - The full month name ("April")
# %e - Day of the month, blank-padded (11)
# %l - Hour of the day, 12-hour clock, blank-padded (1..12)
# %M - Minute of the hour (00..59)
# %p - Meridian indicator, uppercase ("AM" or "PM")
