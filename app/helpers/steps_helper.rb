module StepsHelper

  def div_class_for_step(step)
    "completed" if step.complete?
  end

end

# Explanation of #div_class_for_step(step):
# Calling #complete? on step instance returns true if status attribute value of step instance = 1
# If the step is complete (i.e. its status attribute = 1), then method returns the string "completed"
# which becomes the class attribute value of the div -- <div class="completed">
