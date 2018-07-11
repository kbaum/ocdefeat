class StepDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def position_in_plan
    plan.steps.find_index(step).to_i + 1
  end
end
