module StepsHelper

  def div_class_for_step(step)
    "completed" if step.complete?
  end

  def div_for_plan_steps(plan_steps)
    div_for(plan_steps, class: div_class_for_step(step)) do |step|
      yield
    end
  end

end

# Explanation of #div_class_for_step(step):
# Calling #complete? on step instance returns true if status attribute value of step instance = 1
# If the step is complete (i.e. its status attribute = 1), then method returns the string "completed"
# which becomes the class attribute value of the div -- <div class="completed">

# Explanation of #div_for_plan_steps(plan_steps):
# plan_steps stores array of all steps comprising the plan
# I'm passing this array of AR objects to #div_for
# and this array of steps belonging to the plan will then get iterated over
# and each step record is yielded as an argument for the block.
