module StepsHelper

  def div_class_for_step(step)
    "completed" if step.complete?
  end

  def div_for_step(step)
    div_for(step, class: div_class_for_step(step)) do
      yield
    end
  end

end

# Explanation of #div_class_for_step(step):
# Calling #complete? on step instance returns true if status attribute value of step instance = 1
# If the step is complete (i.e. its status attribute = 1), then method returns the string "completed"
# which becomes the class attribute value of the div -- <div class="completed">

# Explanation of #div_for_step(step):
# I'm create a <div> for the step record (instance)
# the string class attribute value of this <div> is the result of calling #div_class_for_step(step)
# Then we yield to the block. We end up in app/views/steps/_step_div.html.erb partial file,
# where #div_for_step(step) is called, and the code in that file is executed
