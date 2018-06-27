class StepPolicy < ApplicationPolicy # A step does not exist outside the context of an ERP plan

  def create? # The patient who owns the plan off of which the step will be built, and the patient's therapist, can create a new step for that plan
    user.patient? || user.therapist?
  end

  def edit? # Note: if you can't view the parent plan, you can't edit the step
    parent_plan_possessor || therapist_of_parent_plan_possessor
  end
# The patient who created the plan to which the step belongs and that patient's therapist can edit the step
  def update?
    parent_plan_possessor || therapist_of_parent_plan_possessor
  end

  def destroy? # The patient who created the plan to which the step belongs and that patient's therapist can delete the step
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
