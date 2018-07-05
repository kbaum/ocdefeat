class StepPolicy < ApplicationPolicy # A step does not exist outside the context of an ERP plan
  def create?
    user.patient? || user.therapist?
  end

  def edit? # Note: if you can't view the parent plan, you can't edit the step
    parent_plan_possessor || therapist_of_parent_plan_possessor
  end

  def update?
    parent_plan_possessor || therapist_of_parent_plan_possessor
  end

  def destroy?
    parent_plan_possessor || therapist_of_parent_plan_possessor
  end

  private

    def parent_plan_possessor
      user == record.plan.user
    end

    def therapist_of_parent_plan_possessor
      if user.therapist?
        record.plan.in?(user.counselees.map {|counselee| counselee.plans}.flatten)
      end
    end
end
# The patient who created the plan to which the step belongs and that patient's therapist
# can edit the step, delete the step or add a new step to the plan
