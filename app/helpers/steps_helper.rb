module StepsHelper

  def div_class_for_step(step)
    "completed" if step.complete?
  end

end
