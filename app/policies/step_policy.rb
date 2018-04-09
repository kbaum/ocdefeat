class StepPolicy < ApplicationPolicy # A step does not exist outside the context of an ERP plan
  def create? # patient who owns plan to which the step belongs, and any therapist, can create a new step for that plan
    user.patient? || user.therapist?
  end

  private

  def plan_possessor
    user == record.plan.designer
  end
end
