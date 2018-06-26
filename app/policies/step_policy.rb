class StepPolicy < ApplicationPolicy # A step does not exist outside the context of an ERP plan
  def create? # The patient who owns the plan to which the step belongs, and the patient's therapist, can create a new step for that plan
    user.patient? || user.therapist?
  end

  def permitted_attributes # once the step's :plan_id was assigned in steps#create, it cannot be changed
    if user.therapist? || parent_plan_possessor
      [:instructions, :duration, :discomfort_degree, :status]
    end
  end

  def update? # The patient who created the plan to which the step belongs and that patient's therapist can edit the step
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
